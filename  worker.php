<?php

declare(strict_types=1);

use Spiral\RoadRunner\GRPC\Server;
use Spiral\RoadRunner\Worker;
use App\Services\TourShardingService;

require __DIR__ . '/vendor/autoload.php';

// Create RoadRunner worker
$worker = Worker::create();

// Create gRPC server
$server = new Server($worker);

// Register your service
$server->registerService(
    \Tour\V1\TourServiceInterface::class,
    new TourShardingService()
);

// Start handling requests
$server->serve();