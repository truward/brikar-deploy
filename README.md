
## Overview

* Compile application
* Copy to the target location (create or update dir)
* Restart an application

## Lifecycle

```
                (*) Init
                 |
                 |
                 V
                (0) Archive and Remove Old Logs
                 |
                 |
                 V
                (1) Start App
       ____    /   \
 Pull /    V  V     V
 Logs(2)    (3)     (4) Health Check
       \   /   \    /
        +-+     \  /
                 \/
                 |
                 |
                 V
                (+)


3: Get log name, pull logs

4: Periodical healthcheck

```
