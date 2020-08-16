# csv2json

```
$ cat data.csv | csv2json | jq
$ cat data.tsv | csv2json --field-delimiter $'\t' | jq
```

## Installation

Install with Homebrew.

```
$ brew install josh/tap/csv2json
```

Install with [Mint](https://github.com/yonaskolb/Mint).

```
$ mint install josh/csv2json
```

Build from source.

```
$ git clone https://github.com/josh/csv2json
$ cd csv2json
$ swift build -c release
$ cp -f .build/release/csv2json /usr/local/bin/csv2json
```
