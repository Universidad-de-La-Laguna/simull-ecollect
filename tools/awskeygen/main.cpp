#include <QRandomGenerator>
#include <QTextStream>

#include <simplecrypt/simplecrypt.h>

#define STRINGIFY0(v) #v
#define STRINGIFY(v) STRINGIFY0(v)

int main(int argc, char *argv[])
{
    uint64_t awsCryptoKey = AWS_CRYPTO_KEY;
    if (awsCryptoKey == 0)
    {
        awsCryptoKey = QRandomGenerator::global()->generate64();
        QTextStream(stdout) << QString("AWS_CRYPTO_KEY=\"0x%1\"\n").arg(awsCryptoKey, 8, 16);
    }

    SimpleCrypt crypto(awsCryptoKey);
    QTextStream(stdout) << QString("AWS_SECRET_ACCESS_KEY=\"")
            << crypto.encryptToString(QLatin1String(STRINGIFY(AWS_SECRET_ACCESS_KEY)))
            << "\"\n";

    return EXIT_SUCCESS;
}
