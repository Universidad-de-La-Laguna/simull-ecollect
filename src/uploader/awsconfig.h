#pragma once

#include <aws/core/Aws.h>
#include <aws/core/Region.h>

#define STRINGIFY0(v) #v
#define STRINGIFY(v) STRINGIFY0(v)

#if !defined(AWS_ACCESS_KEY_ID)
#define AWS_ACCESS_KEY_ID <access-key-id>
#endif

#if !defined(AWS_SECRET_ACCESS_KEY)
#define AWS_SECRET_ACCESS_KEY <encrypted-secret-access-key>
#endif

#if !defined(AWS_CRYPTO_KEY)
#define AWS_CRYPTO_KEY 0
#endif

#if !defined(AWS_S3_BUCKET_NAME)
#define AWS_S3_BUCKET_NAME <bucket-name>
#endif

namespace AwsConfig {
    const char* ACCESS_KEY_ID = STRINGIFY(ACCESS_KEY_ID);
    const char* SECRET_ACCESS_KEY = STRINGIFY(AWS_SECRET_ACCESS_KEY);
    const char* BUCKET_NAME = STRINGIFY(AWS_S3_BUCKET_NAME);
    const char* REGION = Aws::Region::EU_WEST_1;
};
