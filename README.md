# Microbenchmarks for luajit interpreter

**THIS IS NOT BENCHMARKS FOR JIT!**

Requirements to use microbenchmarks:

* The microbenchmarks is designed to run at fixed CPU frequency with disabled
  frequency boost. How to set fixed CPU frequency and disable frequency boots
  depends on used OS.

  Linux users can do it with:

  ```sh
  # Set fixed CPU frequency
  sudo cpupower frequency-set -f FREQ
  # Disable CPU frequency boost
  echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost
  ```

  Frequency changes may result in inconsistent results.

# Example

*CPU is Elbrus-8C 1.2 GHz*

Avaiable options:

```
$ luajit micro.lua -h
Usage: micro FREQ [FILTER]

Available positional items:
    FREQ                     CPU frequency in GHz
    FILTER                   REGEX strings to filter microbenchmarks

Available options:
    -i N                     Set iteration count to N
    -r N                     Set repeat count to N
    -b                       Load baseline from baseline.csv
    -B PATH                  Load baseline from PATH
    -s                       Save baseline to baseline.csv
    -S PATH                  Save baseline to PATH
```

Run all microbenchmarks:

```
$ luajit micro.lua 1.2
 frequency: 1.2
iterations: 10000
   repeats: 10

      c/i |    c/o | change | change | group                | description
----------|--------|--------|--------|----------------------|-------------
    506.0 |   25.3 | ------ | ------ | ISGT                 | taken
    285.1 |   14.3 | ------ | ------ | ISGT                 | not taken
    526.1 |   26.3 | ------ | ------ | ISGE                 | taken
    286.1 |   14.3 | ------ | ------ | ISGE                 | not taken
    526.1 |   26.3 | ------ | ------ | ISLT                 | taken
    286.1 |   14.3 | ------ | ------ | ISLT                 | not taken
    506.0 |   25.3 | ------ | ------ | ISLE                 | taken
    285.1 |   14.3 | ------ | ------ | ISLE                 | not taken
# truncated...
```

Run microbenchmarks for `ADDVV`:

```
$ luajit micro.lua 1.2 addvv
 frequency: 1.2
iterations: 10000
   repeats: 10
    filter: addvv

      c/i |    c/o | change | change | group                | description
----------|--------|--------|--------|----------------------|-------------
    226.1 |   11.3 | ------ | ------ | ADDVV                | x = x + y
    226.2 |   11.3 | ------ | ------ | ADDVV                | r = x + y
```

Run microbenchmarks for each bytecode that ends with `vn`:

```
$ luajit micro.lua 1.2 vn$
 frequency: 1.2
iterations: 10000
   repeats: 10
    filter: vn$

      c/i |    c/o | change | change | group                | description
----------|--------|--------|--------|----------------------|-------------
    225.1 |   11.3 | ------ | ------ | ADDVN                | x = x + 1
    225.1 |   11.3 | ------ | ------ | ADDVN                | r = x + 1
    225.1 |   11.3 | ------ | ------ | SUBVN                | x = x - 1
    225.1 |   11.3 | ------ | ------ | SUBVN                | r = x - 1
    226.1 |   11.3 | ------ | ------ | MULVN                | x = x * 1
    385.9 |   19.3 | ------ | ------ | DIVVN                | x = x / 1
    385.9 |   19.3 | ------ | ------ | DIVVN                | r = x / 1
    987.7 |   49.4 | ------ | ------ | MODVN                | x = x % 3
    986.6 |   49.3 | ------ | ------ | MODVN                | r = x % 3
```

Use -s flag to save a baseline:

```
$ luajit micro.lua 1.2 add -s
 frequency: 1.2
iterations: 10000
   repeats: 10
    filter: add

      c/i |    c/o | change | change | group                | description
----------|--------|--------|--------|----------------------|-------------
    386.0 |   19.3 | ------ | ------ | ADDVN                | x = x + 1
    385.8 |   19.3 | ------ | ------ | ADDVN                | r = x + 1
    386.9 |   19.3 | ------ | ------ | ADDVV                | x = x + y
    386.2 |   19.3 | ------ | ------ | ADDVV                | r = x + y
```

Optimize code and use -b flag to compare results with the baseline saved with -s flag:

```
$ luajit micro.lua 1.2 add -b
 frequency: 1.2
iterations: 10000
   repeats: 10
    filter: add

      c/i |    c/o | change | change | group                | description
----------|--------|--------|--------|----------------------|-------------
    225.1 |   11.3 |   -8.0 |   -42% | ADDVN                | x = x + 1
    225.1 |   11.3 |   -8.0 |   -42% | ADDVN                | r = x + 1
    226.2 |   11.3 |   -8.0 |   -42% | ADDVV                | x = x + y
    226.2 |   11.3 |   -8.0 |   -41% | ADDVV                | r = x + y
```
