package s3

import (
	"context"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestS3BucketLocalStack(t *testing.T) {
	t.Parallel()

	tf := &terraform.Options{
		TerraformDir: "../../terraform/envs/dev",
		NoColor:      true,
	}

	// Keep the environment clean while iterating. If you prefer, replace with Destroy.
	defer terraform.Destroy(t, tf)

	terraform.InitAndApply(t, tf)

	bucket := terraform.Output(t, tf, "bucket_name")
	endpoint := "http://localhost:4566"
	region := "us-east-1"

	// AWS SDK v2 client configured for LocalStack
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
		config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider("test", "test", "")),
		config.WithEndpointResolverWithOptions(aws.EndpointResolverWithOptionsFunc(
			func(service, region string, _ ...interface{}) (aws.Endpoint, error) {
				if service == s3.ServiceID {
					return aws.Endpoint{URL: endpoint, HostnameImmutable: true}, nil
				}
				return aws.Endpoint{}, &aws.EndpointNotFoundError{}
			},
		)),
	)
	if err != nil {
		t.Fatalf("failed to load AWS config: %v", err)
	}

	s3c := s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.UsePathStyle = true
	})

	// 1) Assert bucket exists
	_, err = s3c.HeadBucket(context.TODO(), &s3.HeadBucketInput{Bucket: &bucket})
	if err != nil {
		t.Fatalf("expected bucket %q to exist; head bucket failed: %v", bucket, err)
	}

	// 2) Put an object
	key := "terratest/hello.txt"
	body := "hello from terratest"
	_, err = s3c.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: &bucket,
		Key:    &key,
		Body:   strings.NewReader(body),
	})
	if err != nil {
		t.Fatalf("put object failed: %v", err)
	}

	// 3) Confirm it appears via ListObjectsV2
	ctx, cancel := context.WithTimeout(context.TODO(), 10*time.Second)
	defer cancel()

	out, err := s3c.ListObjectsV2(ctx, &s3.ListObjectsV2Input{
		Bucket: &bucket,
		Prefix: aws.String("terratest/"),
	})
	if err != nil {
		t.Fatalf("list objects failed: %v", err)
	}
	if len(out.Contents) == 0 {
		t.Fatalf("expected at least 1 object under terratest/ prefix")
	}
}
