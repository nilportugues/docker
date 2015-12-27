#!/usr/bin/env bash

SHARED='docker/docker-compose.yml'

case "$1" in
    start)
        docker-compose -f $SHARED start;
        ;;
    stop)
        docker-compose -f $SHARED stop;
        ;;
    init)
        docker-compose -f $SHARED up --force-recreate -d;
        ;;
    destroy)
        docker-compose -f $SHARED stop;
        docker-compose -f $SHARED rm;
        ;;
    update)
        docker-compose -f $SHARED stop;
        docker-compose -f $SHARED build;
        docker-compose -f $SHARED up --force-recreate -d;
        ;;
    *)
        echo "Options to use: {start|stop|init|destroy|update}"
        exit 1
        ;;
esac

