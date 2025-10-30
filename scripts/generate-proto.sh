
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

# Lưu ý: plugin RoadRunner (protoc-gen-php-grpc) KHÔNG sinh client stub kiểu *Client.php.
# Bạn sẽ dùng `Spiral\\RoadRunner\\GRPC\\Client` kết hợp với interface sinh ra (ví dụ: Tour\\V1\\TourServiceInterface).

echo "✅ Proto generation completed!"
echo ""
echo "Generated files are in: ./generated/"
echo ""
echo "Next steps:"
echo "1. Run: composer dump-autoload"
echo "2. Start RoadRunner: rr serve"