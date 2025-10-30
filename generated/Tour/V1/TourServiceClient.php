<?php

namespace Tour\V1;

use Grpc\BaseStub;
use Grpc\Channel;
use Grpc\UnaryCall;

class TourServiceClient extends BaseStub
{
    /**
     * @throws \Exception
     */
    public function __construct(string $hostname, array $opts, ?Channel $channel = null)
    {
        parent::__construct($hostname, $opts, $channel);
    }

    /**
     * @return UnaryCall
     */
    public function GetTourById(GetTourByIdRequest $argument, array $metadata = [], array $options = []): UnaryCall
    {
        return $this->_simpleRequest(
            '/tour.TourService/GetTourById',
            $argument,
            ['\\Tour\\V1\\TourResponse', 'decode'],
            $metadata,
            $options
        );
    }

    /**
     * @return UnaryCall
     */
    public function ListTours(ListToursRequest $argument, array $metadata = [], array $options = []): UnaryCall
    {
        return $this->_simpleRequest(
            '/tour.TourService/ListTours',
            $argument,
            ['\\Tour\\V1\\ListToursResponse', 'decode'],
            $metadata,
            $options
        );
    }
}


