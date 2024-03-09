# SocToProc
## Script will read all UIDs from /proc/self/net/* files and map these to the file descriptiors for each process (/proc/*/fd) to map the socket to the PID. It sill also parse the IPs and ports reltated to the connection to a more human readable form. Output will contain more info around the process.


## Usage
Option | Explanation
--- | ---
-c  | Print output as csv to stdout.
-h  | Print help message


## Examples
```
# Run on live system and print to stdout
sudo ./SocToProc.sh

# Run on live system and print CSV format to stdout
sudo ./SocToProc.sh -c
 
```

## Limitations
* Script in live mode will deal with a live system. This means change in running processes, network connections etc. while the script is running.
* I have not added an offline mode yet.

## Author
* Mastodon: [@b00010111](https://ioc.exchange/@b00010111)
* Blog: https://00010111.at/

## License
* Free to use, reuse and redistribute for everyone.
* No Limitations.
* Of course attribution is always welcome but not mandatory.

## Bugs, Discussions, Feature requests, contact
* open an issue
* contact me via Mastodon
* (reaching out via Twitter doesn't really work well anymore...sorry)

## further reading


## Change History
 * Version 0.001:
    * initial release
