#compdef just

autoload -U is-at-least

_just() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    local common=(
'--chooser=[Override binary invoked by \`--choose\`]: : ' \
'--color=[Print colorful output]: :(auto always never)' \
'--command-color=[Echo recipe lines in <COMMAND-COLOR>]: :(black blue cyan green purple red yellow)' \
'(-E --dotenv-path)--dotenv-filename=[Search for environment file named <DOTENV-FILENAME> instead of \`.env\`]: : ' \
'-E+[Load <DOTENV-PATH> as environment file instead of searching for one]: :_files' \
'--dotenv-path=[Load <DOTENV-PATH> as environment file instead of searching for one]: :_files' \
'--dump-format=[Dump justfile as <FORMAT>]:FORMAT:(json just)' \
'-f+[Use <JUSTFILE> as justfile]: :_files' \
'--justfile=[Use <JUSTFILE> as justfile]: :_files' \
'--list-heading=[Print <TEXT> before list]:TEXT: ' \
'--list-prefix=[Print <TEXT> before each list item]:TEXT: ' \
'*--set=[Override <VARIABLE> with <VALUE>]: :(_just_variables)' \
'--shell=[Invoke <SHELL> to run recipes]: : ' \
'*--shell-arg=[Invoke shell with <SHELL-ARG> as an argument]: : ' \
'--timestamp-format=[Timestamp format string]: : ' \
'-d+[Use <WORKING-DIRECTORY> as working directory. --justfile must also be set]: :_files' \
'--working-directory=[Use <WORKING-DIRECTORY> as working directory. --justfile must also be set]: :_files' \
'*-c+[Run an arbitrary command with the working directory, \`.env\`, overrides, and exports set]: : ' \
'*--command=[Run an arbitrary command with the working directory, \`.env\`, overrides, and exports set]: : ' \
'--completions=[Print shell completion script for <SHELL>]:SHELL:(bash elvish fish nushell powershell zsh)' \
'()-l+[List available recipes]' \
'()--list=[List available recipes]' \
'-s+[Show recipe at <PATH>]: :(_just_commands)' \
'--show=[Show recipe at <PATH>]: :(_just_commands)' \
'--check[Run \`--fmt\` in '\''check'\'' mode. Exits with 0 if justfile is formatted correctly. Exits with 1 and prints a diff if formatting is required.]' \
'--clear-shell-args[Clear shell arguments]' \
'(-q --quiet)-n[Print what just would do without doing it]' \
'(-q --quiet)--dry-run[Print what just would do without doing it]' \
'(-f --justfile -d --working-directory)-g[Use global justfile]' \
'(-f --justfile -d --working-directory)--global-justfile[Use global justfile]' \
'--highlight[Highlight echoed recipe lines in bold]' \
'--list-submodules[List recipes in submodules]' \
'--no-aliases[Don'\''t show aliases in list]' \
'--no-deps[Don'\''t run recipe dependencies]' \
'--no-dotenv[Don'\''t load \`.env\` file]' \
'--no-highlight[Don'\''t highlight echoed recipe lines in bold]' \
'(-n --dry-run)-q[Suppress all output]' \
'(-n --dry-run)--quiet[Suppress all output]' \
'--shell-command[Invoke <COMMAND> with the shell used to run recipe lines and backticks]' \
'--timestamp[Print recipe command timestamps]' \
'-u[Return list and summary entries in source order]' \
'--unsorted[Return list and summary entries in source order]' \
'--unstable[Enable unstable features]' \
'*-v[Use verbose output]' \
'*--verbose[Use verbose output]' \
'--yes[Automatically confirm all recipes.]' \
'--changelog[Print changelog]' \
'--choose[Select one or more recipes to run using a binary chooser. If \`--chooser\` is not passed the chooser defaults to the value of \$JUST_CHOOSER, falling back to \`fzf\`]' \
'--dump[Print justfile]' \
'-e[Edit justfile with editor given by \$VISUAL or \$EDITOR, falling back to \`vim\`]' \
'--edit[Edit justfile with editor given by \$VISUAL or \$EDITOR, falling back to \`vim\`]' \
'--evaluate[Evaluate and print all variables. If a variable name is given as an argument, only print that variable'\''s value.]' \
'--fmt[Format and overwrite justfile]' \
'--groups[List recipe groups]' \
'--init[Initialize new justfile in project root]' \
'--man[Print man page]' \
'--summary[List names of available recipes]' \
'--variables[List names of variables]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
)

    _arguments "${_arguments_options[@]}" $common \
        '1: :_just_commands' \
        '*: :->args' \
        && ret=0

    case $state in
        args)
            curcontext="${curcontext%:*}-${words[2]}:"

            local lastarg=${words[${#words}]}
            local recipe

            local cmds; cmds=(
                ${(s: :)$(_call_program commands just --summary)}
            )

            # Find first recipe name
            for ((i = 2; i < $#words; i++ )) do
                if [[ ${cmds[(I)${words[i]}]} -gt 0 ]]; then
                    recipe=${words[i]}
                    break
                fi
            done

            if [[ $lastarg = */* ]]; then
                # Arguments contain slash would be recognised as a file
                _arguments -s -S $common '*:: :_files'
            elif [[ $lastarg = *=* ]]; then
                # Arguments contain equal would be recognised as a variable
                _message "value"
            elif [[ $recipe ]]; then
                # Show usage message
                _message "`just --show $recipe`"
                # Or complete with other commands
                #_arguments -s -S $common '*:: :_just_commands'
            else
                _arguments -s -S $common '*:: :_just_commands'
            fi
        ;;
    esac

    return ret

}

(( $+functions[_just_commands] )) ||
_just_commands() {
    [[ $PREFIX = -* ]] && return 1
    integer ret=1
    local variables; variables=(
        ${(s: :)$(_call_program commands just --variables)}
    )
    local commands; commands=(
        ${${${(M)"${(f)$(_call_program commands just --list)}":#    *}/ ##/}/ ##/:Args: }
    )

    if compset -P '*='; then
        case "${${words[-1]%=*}#*=}" in
            *) _message 'value' && ret=0 ;;
        esac
    else
        _describe -t variables 'variables' variables -qS "=" && ret=0
        _describe -t commands 'just commands' commands "$@"
    fi

}

if [ "$funcstack[1]" = "_just" ]; then
    (( $+functions[_just_variables] )) ||
_just_variables() {
    [[ $PREFIX = -* ]] && return 1
    integer ret=1
    local variables; variables=(
        ${(s: :)$(_call_program commands just --variables)}
    )

    if compset -P '*='; then
        case "${${words[-1]%=*}#*=}" in
            *) _message 'value' && ret=0 ;;
        esac
    else
        _describe -t variables 'variables' variables && ret=0
    fi

    return ret
}

_just "$@"
else
    compdef _just just
fi