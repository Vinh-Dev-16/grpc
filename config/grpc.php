<?php

return [
    /*
    |--------------------------------------------------------------------------
    | gRPC Services Configuration
    |--------------------------------------------------------------------------
    |
    | Cấu hình các service gRPC để sharding
    |
    */

    'services' => [
        'default' => [
            'host' => env('GRPC_HOST', '0.0.0.0'),
            'port' => env('GRPC_PORT', 9090),
            'timeout' => env('GRPC_TIMEOUT', 5000),
        ],
    ],

    'sharding' => [
        'strategy' => env('GRPC_SHARDING_STRATEGY', 'round_robin'), // round_robin, hash, random
        'services' => [
            // Thêm các service endpoint ở đây
            // 'service1' => ['host' => 'localhost', 'port' => 9091],
            // 'service2' => ['host' => 'localhost', 'port' => 9092],
        ],
    ],
];

