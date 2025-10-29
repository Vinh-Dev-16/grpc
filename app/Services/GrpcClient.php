<?php

namespace App\Services;

use Grpc\ChannelCredentials;
use Grpc\BaseStub;

class GrpcClient
{
    protected array $services;
    protected string $shardingStrategy;
    protected int $currentIndex = 0;

    public function __construct()
    {
        $this->services = config('grpc.sharding.services', []);
        $this->shardingStrategy = config('grpc.sharding.strategy', 'round_robin');
    }

    /**
     * Lấy service endpoint dựa trên sharding strategy
     */
    protected function getServiceEndpoint(?string $key = null): ?array
    {
        if (empty($this->services)) {
            $default = config('grpc.services.default');
            return [
                'host' => $default['host'],
                'port' => $default['port'],
            ];
        }

        return match ($this->shardingStrategy) {
            'hash' => $this->getHashService($key),
            'random' => $this->getRandomService(),
            default => $this->getRoundRobinService(),
        };
    }

    /**
     * Round-robin sharding
     */
    protected function getRoundRobinService(): array
    {
        $services = array_values($this->services);
        $service = $services[$this->currentIndex % count($services)];
        $this->currentIndex++;
        
        return $service;
    }

    /**
     * Hash-based sharding
     */
    protected function getHashService(?string $key): array
    {
        $services = array_values($this->services);
        $hash = crc32($key ?? uniqid());
        $index = abs($hash) % count($services);
        
        return $services[$index];
    }

    /**
     * Random sharding
     */
    protected function getRandomService(): array
    {
        $services = array_values($this->services);
        
        return $services[array_rand($services)];
    }

    /**
     * Tạo gRPC client stub
     */
    public function createClient(string $clientClass, ?string $shardKey = null): BaseStub
    {
        $endpoint = $this->getServiceEndpoint($shardKey);
        $hostname = "{$endpoint['host']}:{$endpoint['port']}";
        
        return new $clientClass($hostname, [
            'credentials' => ChannelCredentials::createInsecure(),
        ]);
    }

    /**
     * Gọi gRPC method
     */
    public function call(string $clientClass, string $method, $request, ?string $shardKey = null)
    {
        $client = $this->createClient($clientClass, $shardKey);
        
        [$response, $status] = $client->$method($request)->wait();
        
        if ($status->code !== \Grpc\STATUS_OK) {
            throw new \RuntimeException("gRPC Error: {$status->code} - {$status->details}");
        }
        
        return $response;
    }
}

