#!/usr/bin/expect

set password [lindex $argv 0]
set coldkey [lindex $argv 1]
set hotkey [lindex $argv 2]
set netuid [lindex $argv 3]
set timeout 30  ;# Increase timeout value
set retry_interval 10  ;# Reduced retry interval

# Function to get the current timestamp
proc timestamp {} {
    set now [clock seconds]
    set date [clock format $now -format "%Y-%m-%d %H:%M:%S"]
    return $date
}


# Function for registration
proc registration {} {
    global netuid
    global password
    global coldkey
    global hotkey
    spawn btcli s pow-register --netuid $netuid --wallet.name $coldkey --wallet.hotkey $hotkey --yes --processors 4 --cuda

    # Log timestamp for registration attempt
    puts "[timestamp] Attempting registration..."

    expect "Enter your password: " {
        send "$password\r"
        expect ""
    }

    expect {
        -re "❌ Failed.*" {
            puts "[timestamp] Error encountered: TooManyRegistrationsThisInterval or ❌ Failed. Restarting..."
        }
        -re {.*SubstrateRequestException\(Invalid Transaction\).*Custom error: 6.*} {
            puts "[timestamp] Error encountered: SubstrateRequestException(Invalid Transaction) | Custom error 6"
        }
        -re ".*Registered.*" {
            puts "[timestamp] Registration completed successfully."
        }
        -timeout 180 {
            puts "[timestamp] Timeout: Restarting..."
        }
        eof {
            puts "[timestamp] Unexpected EOF: Restarting..."
        }
    }
}

# Run the registration function
registration
puts "[timestamp] Script completed."
