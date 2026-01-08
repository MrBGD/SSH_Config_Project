# --- Duplicate Checks ---
# This should trigger [DUPLICATE]
MaxAuthTries 6
MaxAuthTries 6

# This should trigger [OVERWRITE]
LoginGraceTime 30
LoginGraceTime 60

# --- Parsing Edge Cases ---
# Weird spacing (tabs and spaces) - Script should handle this fine
Port    2222
   PermitRootLogin    no

# Comments without spaces (your script used to crash on this)
#CommentWithoutSpace

# --- Whitelist Check ---
# These are allowed multiple times. Should NOT trigger overwrite/duplicate
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# --- The Match Block ---
# Script should STOP checking here.
# If it continues, it will falsely flag 'PasswordAuthentication yes' as a global fail.
Match User deploy
    PasswordAuthentication yes
    PermitRootLogin yes