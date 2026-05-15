# env.mk - configuration variables for the JOS lab

# '$(V)' controls whether the lab makefiles print verbose commands (the
# actual shell commands run by Make), as well as the "overview" commands
# (such as '+ cc lib/readline.c').
#
# For overview commands only, the line should read 'V = @'.
# For overview and verbose commands, the line should read 'V ='.
V =

# If your system-standard GNU toolchain is not ELF-compatible, uncomment
# and edit the following line to use those tools. The value should be the
# prefix portion of the command names (e.g., /usr/bin/x86_64-linux-gnu-gcc
# would define GCCPREFIX=x86_64-linux-gnu-)
#
# GCCPREFIX=
