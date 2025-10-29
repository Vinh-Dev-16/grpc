<?php

declare(strict_types=1);

namespace App\Services;

use Spiral\RoadRunner\GRPC\ContextInterface;
use Tour\V1\GetTourByIdRequest;
use Tour\V1\TourResponse;
use Tour\V1\ListToursRequest;
use Tour\V1\ListToursResponse;
use Tour\V1\TourServiceInterface;
use Grpc\ChannelCredentials;

class TourShardingService implements TourServiceInterface
{
    private string $tourServiceHost;
    private int $tourServicePort;

    public function __construct()
    {
        $this->tourServiceHost = getenv('TOUR_SERVICE_HOST') ?: 'localhost';
        $this->tourServicePort = (int)(getenv('TOUR_SERVICE_PORT') ?: 9002);
    }

    /**
     * Get tour by ID - Forward to Tour Service
     */
    public function GetTourById(ContextInterface $ctx, GetTourByIdRequest $in): TourResponse
    {
        try {
            // Tạo gRPC client để call sang Tour Service
            $client = $this->createTourServiceClient();

            // Forward request
            [$response, $status] = $client->GetTourById($in)->wait();

            if ($status->code !== \Grpc\STATUS_OK) {
                throw new \Exception("Tour service error: " . $status->details);
            }

            return $response;

        } catch (\Exception $e) {
            // Log error
            error_log("Error in GetTourById: " . $e->getMessage());

            // Return empty response hoặc throw exception
            $response = new TourResponse();
            $response->setId(0);
            $response->setName("Error: " . $e->getMessage());

            return $response;
        }
    }

    /**
     * List tours - Forward to Tour Service
     */
    public function ListTours(ContextInterface $ctx, ListToursRequest $in): ListToursResponse
    {
        try {
            $client = $this->createTourServiceClient();

            [$response, $status] = $client->ListTours($in)->wait();

            if ($status->code !== \Grpc\STATUS_OK) {
                throw new \Exception("Tour service error: " . $status->details);
            }

            return $response;

        } catch (\Exception $e) {
            error_log("Error in ListTours: " . $e->getMessage());

            $response = new ListToursResponse();
            $response->setTotal(0);

            return $response;
        }
    }

    /**
     * Create gRPC client to Tour Service
     */
    private function createTourServiceClient(): \Tour\V1\TourServiceClient
    {
        $hostname = $this->tourServiceHost . ':' . $this->tourServicePort;

        return new \Tour\V1\TourServiceClient(
            $hostname,
            [
                'credentials' => ChannelCredentials::createInsecure(),
            ]
        );
    }
}