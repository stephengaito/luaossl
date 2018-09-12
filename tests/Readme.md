# PKey:encrypt and PKey:decrypt seg-fault analysis

This could be related to the following issue [SIGSEGV on pk_decrypt() 
number 98](https://github.com/wahern/luaossl/issues/98) In this case the 
was identified as a construction of a public key *with not corresponding 
private key* (which does happen in my tests). A work around was to [call 
setParameters](https://github.com/wahern/luaossl/issues/98#issuecomment-326804833).

I found a simple call to toPEM *just after creating the key* cleared the 
problems. (See below)

### Segmentation Fault

There is a segmentation fault which seems to result from lua-ossl's 
interaction between BIO, and pk_encrypt/pk_decrypt.

IF we create the a key, (public or private), then encrypt (or decrpyt) some 
text using the public (or private) key, we get a segmentation fault.

However, with either key, if we make a call to the toPEM("public") method 
**before** the corresponding encryption or decryption we get no 
segmentation fault.

By hacking the lua-ossl code openssl.c (in pk_decrypt at line 3863; in 
pk_encrypt at line 3921) I determined the segmentation fault happens in the 
"BIO_get_mem_ptr(bio, &buf);" statement:

>        bio = getbio(L);
>        printf("bio = %p\n", bio); fflush(stdout);
>        BIO_get_mem_ptr(bio, &buf);
>        printf("buf = %p\n", buf); fflush(stdout);

With a 'toPEM("public")' statement just after the creation of either the 
public or private keys there is NO seg-fault. Without the 'toPEM("public")' 
statement there is a seg-fault getting the mem_ptr. This happens in all 
Luas (5.1, 5.2, and 5.3). In all cases the bio pointer is NOT null and 
"looks reasonable".

### Work around

**NOTE: call toPEM("public") on any key just after it is created!**

### Running tests

These tests should be run in the base directory of the luaossl distribution.

You **must** have the luaunit.lua luarock somewhere in your lua 
package.path.

Type one of the following:

> lua5.1 tests/test5.1.lua

or

> lua5.2 tests/test5.2.lua

or 

> lua5.3 tests/test5.3.lua

### Current system

On 20180912 I had the following system:

> uname -a
> Linux xxxx 4.15.0-33-generic #36-Ubuntu SMP Wed Aug 15 16:00:05 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux

---

> sudo apt list --installed | grep gcc
> 
> WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
> 
> gcc/bionic,now 4:7.3.0-3ubuntu2 amd64 [installed,automatic]
> gcc-7/bionic,now 7.3.0-16ubuntu3 amd64 [installed,automatic]
> gcc-7-base/bionic,now 7.3.0-16ubuntu3 amd64 [installed]
> gcc-8-base/bionic,now 8-20180414-1ubuntu2 amd64 [installed]
> lib32gcc-7-dev/bionic,now 7.3.0-16ubuntu3 amd64 [installed,automatic]
> lib32gcc1/bionic,now 1:8-20180414-1ubuntu2 amd64 [installed,automatic]
> libcaca0/bionic,now 0.99.beta19-2build2~gcc5.3 amd64 [installed]
> libgcc-7-dev/bionic,now 7.3.0-16ubuntu3 amd64 [installed,automatic]
> libgcc1/bionic,now 1:8-20180414-1ubuntu2 amd64 [installed]
> libx32gcc1/bionic,now 1:8-20180414-1ubuntu2 amd64 [installed,automatic]

---

> sudo apt list --installed | grep ssl
> 
> WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
> 
> libio-socket-ssl-perl/bionic,bionic,now 2.056-1 all [installed]
> libnet-smtp-ssl-perl/bionic,bionic,now 1.04-1 all [installed]
> libnet-ssleay-perl/bionic,now 1.84-1build1 amd64 [installed]
> libssl-dev/bionic-updates,bionic-security,now 1.1.0g-2ubuntu4.1 amd64 [installed]
> libssl-doc/bionic-updates,bionic-updates,bionic-security,bionic-security,now 1.1.0g-2ubuntu4.1 all [installed,automatic]
> libssl1.0.0/bionic-updates,bionic-security,now 1.0.2n-1ubuntu5.1 amd64 [installed]
> libssl1.1/bionic-updates,bionic-security,now 1.1.0g-2ubuntu4.1 amd64 [installed]
> lua-luaossl/bionic,now 20161214-1build1 amd64 [installed,automatic]
> lua-luaossl-dev/bionic,now 20161214-1build1 amd64 [installed]
> openssl/bionic-updates,bionic-security,now 1.1.0g-2ubuntu4.1 amd64 [installed]
> perl-openssl-defaults/bionic,now 3build1 amd64 [installed]
> ssl-cert/bionic,bionic,now 1.0.39 all [installed]

---

> sudo apt list --installed | grep lua
> 
> WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
> 
> liblua5.1-0/bionic,now 5.1.5-8.1build2 amd64 [installed,automatic]
> liblua5.1-0-dev/bionic,now 5.1.5-8.1build2 amd64 [installed]
> liblua5.2-0/bionic,now 5.2.4-1.1build1 amd64 [installed,automatic]
> liblua5.2-dev/bionic,now 5.2.4-1.1build1 amd64 [installed]
> liblua5.3-0/bionic,now 5.3.3-1 amd64 [installed,automatic]
> liblua5.3-dev/bionic,now 5.3.3-1 amd64 [installed]
> libluajit-5.1-2/bionic,now 2.1.0~beta3+dfsg-5.1 amd64 [installed,automatic]
> libluajit-5.1-common/bionic,bionic,now 2.1.0~beta3+dfsg-5.1 all [installed,automatic]
> lua-any/bionic,bionic,now 24 all [installed,automatic]
> lua-luaossl/bionic,now 20161214-1build1 amd64 [installed,automatic]
> lua-luaossl-dev/bionic,now 20161214-1build1 amd64 [installed]
> lua-sec/bionic,now 0.6-4 amd64 [installed,automatic]
> lua-socket/bionic,now 3.0~rc1+git+ac3201d-4 amd64 [installed,automatic]
> lua-unit/bionic,bionic,now 3.2-1 all [installed]
> lua5.1/bionic,now 5.1.5-8.1build2 amd64 [installed]
> lua5.2/bionic,now 5.2.4-1.1build1 amd64 [installed]
> lua5.3/bionic,now 5.3.3-1 amd64 [installed]
> luarocks/bionic,bionic,now 2.4.2+dfsg-1 all [installed]

