<?php

declare(strict_types=1);

use Spiral\RoadRunner\GRPC\Invoker;
use Spiral\RoadRunner\GRPC\Server;
use App\Services\TourShardingService;
use Tour\V1\TourServiceInterface;

require __DIR__ . '/vendor/autoload.php';

// Create gRPC server
$server = new Server(new Invoker());

// Register your service
$server->registerService(
    TourServiceInterface::class,
    new TourShardingService()
);

// Start handling requests
$server->serve();