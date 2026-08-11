#!/bin/bash

for i in {1..30}; do
    if curl --fail http://localhost/; then
        exit 0
    fi

    sleep 5
done

exit 1