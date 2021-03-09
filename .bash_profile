export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH


# Fuzzing
ffuf_quick(){
    dom=$(echo $1 | unfurl format %s%d)
    ffuf -c -v -t 20 -u $1/FUZZ -w ~/tools/wordlists/quick.txt \
    -H "User-Agent: Mozilla Firefox Mozilla/5.0" \
    -H "X-Bug-Bounty: caesarsec" -ac -mc all \
    -o quick_$dom.csv -of csv $2 -maxtime 360 $3
}


ffuf_recursive(){
    mkdir -p recursive
    dom=$(echo $1 | unfurl format %s%d)
    ffuf -c -v -t 20 -u $1/FUZZ -w $2 \
    -H "User-Agent: Mozilla Firefox Mozilla/5.0"
    -H "X-Bug-Bounty: caesarsec" \
    -recursive -recursion-depth 5 -mc all -ac \
    -o recursive/recursive_$dom.csv -0of csv $3
}


# Nuclei

nuclei_site(){
    echo $1 | nuclei -t vulnerabilities/ -t fuzzing/ -t misconfiguration/ \
    -t miscellaneous/dir-listing.yaml -c 30
}

nuclei_file(){
    nuclei -l $1 -t vulnerabilities/ -t fuzzing/ -t misconfiguration/ \
        -t miscellaneous/dir-listing.yaml -c 50
}


# wordlist-moding

add_to_lists(){
    echo $1 | anew ~/tools/wordlists/quick.txt
    echo $1 | anew ~/tools/wordlists/recursive.txt
    echo $1 | anew ~/tools/wordlists/mega.txt
}

add_to_lists_from_file(){
    while read line; do add_to_lists $line;done < $1
}



# Misc.

# Usage: arjun https://google.com get
arjun(){
    here=$(pwd)
    cd ~/tools/Arjun
    python3 arjun.py -u $1 -m $2 -w db/params.txt
    cd $here
}


# Usage: tamper https://site.com
tamper(){
    echo -n "$1: "; for i in GET POST HEAD PUT DELETE CONNECT OPTIONS TRACE PATCH ASDF; \
        do echo "echo -n \"$i-$(curl -k -s -X $i $1 -o /dev/null -w '%{http_code}') \""; done \
        | parallel -j 10 ; echo
}


# Usage: linkfinder https://site.com/main.js | anew paths.txt

linkfinder(){
    python3 ~/tools/LinkFinder/linkfinder.py -i $1 $2 -o cli \
    | grep -v http | grep -v // | sed 's/^\.\//\//' | sed 's/^\///'
}


#Usage: hakrawler to find paths in js files. (Used for high depth count)

crawler(){
    hakrawler -url dochub.com -scope subs -plain -js -usewayback | tee -a js_files;
}


# nmap

scan_single(){
    nmap -T4 -sS -Pn -p1-65535 $1
}

scan_multi(){
    nmap -T4 -sS -Pn -p1-65535 -iL $1
}




#__Recon___

certprobe(){ #runs httprobe on all the hosts from certspotter
curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httprobe | tee -a ./all.txt

}
