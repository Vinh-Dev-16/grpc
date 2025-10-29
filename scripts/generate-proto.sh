
#!/bin/bash

# Script để generate PHP code từ proto files

set -e

echo "🚀 Generating PHP code from proto files..."

# Tạo thư mục output nếu chưa có
mkdir -p generated

# Generate PHP classes từ proto files
# Tìm tất cả file .proto trong thư mục proto và subdirectories
find proto -name "*.proto" -print0 | while IFS= read -r -d '' proto_file; do
    echo "📄 Generating from: $proto_file"
    protoc --proto_path=proto \
        --php_out=generated \
        --plugin=protoc-gen-php-grpc=/usr/local/bin/protoc-gen-php-grpc \
        --php-grpc_out=generated \
        "$proto_file"
done

# Nếu không tìm thấy file nào, thử với proto/tour.proto trực tiếp
if [ ! -f generated/Tour/V1/TourServiceClient.php ]; then
    echo "📄 Generating from proto/tour.proto (direct path)..."
    protoc --proto_path=proto \
        --php_out=generated \
        --plugin=protoc-gen-php-grpc=/usr/local/bin/protoc-gen-php-grpc \
        --php-grpc_out=generated \
        proto/tour.proto
fi

echo "✅ Proto generation completed!"
echo ""
echo "Generated files are in: ./generated/"
echo ""
echo "Next steps:"
echo "1. Run: composer dump-autoload"
echo "2. Start RoadRunner: rr serve"