function __bb_usage
    printf "# buck build

Description:
    Call 'buck build' with targets from current directory. Default builds all targets.

Usage:
    bb [option] <target>

Examples:
    # You are in /home/user/dev/path/is/very/long/
    # And your repo is /home/user/dev
    > bb
    # is equivalent to buck build //path/is/very/long:
    > bb banana
    # is equivalent to buck build //path/is/very/long:banana

Options:
    -d      Build with @mode/dbg
    -l      List all available targets
    -t      Test
    -h      Print help
"
end

function bb

    set -l pwd (pwd)
    set -l buckdir (pwd | sed 's|.*\/fbcode\/\(.*\)|\1|')
    set -l args (getopt "lhdt" $argv)

    if [ $status -gt 0 ]
        __bb_usage
        return 1
    end

    set args (echo $args | sed 's/^\s//' | tr ' ' '\n')

    set -l i 1
    set -l command build
    set -l mode
    for arg in $args
        switch $arg
        case "-h"
            __bb_usage
            return 0
        case "-d"
            echo Debug mode enabled
            set mode @mode/dbg
        case "-l"
            set command targets
        case "-t"
            set command test
        case "--"
            set i (math $i + 1)
            break
        end
        set i (math $i + 1)
    end

    set -l target
    if [ $i -gt (count $args) ]
      set target :
    else
      set target :$args[$i]
    end

    echo buck $command $mode $buckdir$target
    buck $command $mode $buckdir$target
end
