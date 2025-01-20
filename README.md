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
$ luajit -j off micro.lua -h
usage: micro freq [filter]

 -n N
 -r N
 -b          read baseline
 -s          save baseline
```

Run all microbenchmarks:

```
$ luajit -j off micro.lua 1.2 
 frequency: 1.2
iterations: 10000
   repeats: 10

   time |      c/i |    c/o | change | Bytecode | Description
--------|----------|--------|--------|----------|-------------
   0.00 |    505.9 |   25.3 | ------ | ISGT     | taken
   0.00 |    285.1 |   14.3 | ------ | ISGT     | not taken
   0.00 |    525.8 |   26.3 | ------ | ISGE     | taken
   0.00 |    286.2 |   14.3 | ------ | ISGE     | not taken
   0.00 |    526.0 |   26.3 | ------ | ISLT     | taken
   0.00 |    286.1 |   14.3 | ------ | ISLT     | not taken
   0.00 |    505.9 |   25.3 | ------ | ISLE     | taken
   0.00 |    285.1 |   14.3 | ------ | ISLE     | not taken
   0.01 |    826.1 |   41.3 | ------ | ISEQV    | taken
# truncated...
```

Run microbenchmarks for `ADDVV`:

```
$ luajit -j off micro.lua 1.2 addvv
 frequency: 1.2
iterations: 10000
   repeats: 10
    filter: addvv

   time |      c/i |    c/o | change | Bytecode | Description
--------|----------|--------|--------|----------|-------------
   0.00 |    226.1 |   11.3 | ------ | ADDVV    | x = x + y
   0.00 |    226.1 |   11.3 | ------ | ADDVV    | r = x + y
```

Run microbenchmarks for each bytecode that ends with `vn`:

```
$ luajit -j off micro.lua 1.2 vn$
 frequency: 1.2
iterations: 10000
   repeats: 10
    filter: vn$

   time |      c/i |    c/o | change | Bytecode | Description
--------|----------|--------|--------|----------|-------------
   0.00 |    225.1 |   11.3 | ------ | ADDVN    | x = x + 1
   0.00 |    225.1 |   11.3 | ------ | ADDVN    | x = x + 1
   0.00 |    225.1 |   11.3 | ------ | ADDVN    | r = x + 1
   0.00 |    225.1 |   11.3 | ------ | SUBVN    | x = x - 1
   0.00 |    225.1 |   11.3 | ------ | SUBVN    | x = x - 1
   0.00 |    225.1 |   11.3 | ------ | SUBVN    | r = x - 1
   0.00 |    226.2 |   11.3 | ------ | MULVN    | x = x * 1
   0.00 |    226.1 |   11.3 | ------ | MULVN    | r = x * 1
   0.00 |    385.2 |   19.3 | ------ | DIVVN    | x = x / 1
   0.00 |    386.0 |   19.3 | ------ | DIVVN    | r = x / 1
   0.01 |    986.9 |   49.3 | ------ | MODVN    | x = x % 3
   0.01 |    986.9 |   49.3 | ------ | MODVN    | r = x % 3
```

Use -s flag to save a baseline:

```
$ luajit -j off micro.lua 1.2 add -s
 frequency: 1.2
iterations: 10000
   repeats: 10
    filter: add

   time |      c/i |    c/o | change | Bytecode | Description
--------|----------|--------|--------|----------|-------------
   0.00 |    225.1 |   11.3 | ------ | ADDVN    | x = x + 1
   0.00 |    225.1 |   11.3 | ------ | ADDVN    | x = x + 1
   0.00 |    225.1 |   11.3 | ------ | ADDVN    | r = x + 1
   0.00 |    226.2 |   11.3 | ------ | ADDVV    | x = x + y
   0.00 |    226.1 |   11.3 | ------ | ADDVV    | r = x + y
```

Use -b flag to compare results with the baseline saved with -s flag:

```
$ luajit -j off micro.lua 1.2 add -b
 frequency: 1.2
iterations: 10000
   repeats: 10
    filter: add

   time |      c/i |    c/o | change | Bytecode | Description
--------|----------|--------|--------|----------|-------------
   0.00 |    225.1 |   11.3 |   -0.0 | ADDVN    | x = x + 1
   0.00 |    225.1 |   11.3 |   -0.0 | ADDVN    | x = x + 1
   0.00 |    225.1 |   11.3 |    0.0 | ADDVN    | r = x + 1
   0.00 |    226.1 |   11.3 |   -0.0 | ADDVV    | x = x + y
   0.00 |    226.2 |   11.3 |    0.0 | ADDVV    | r = x + y
```
