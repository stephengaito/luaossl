-- Some LuaUnit tests of the luaossl pkey.encrypt and pkey.decrypt 
-- functions.

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

lu = require "luaunit"

-- This is how we should NORMALLY require pkey
-- local pkey = require "openssl.pkey" 

-- BUT this is how we must do it in the preinstalled state
local pkey = require "_openssl.pkey"

TestPKeyEncryption = {}

-- We test the encryption and then decryption of a simple 
-- plaintext.
--
function TestPKeyEncryption:testEncryptDecrypt()

	publicKeyStr = [[-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCqRwqWC/MRtZjYO/r07iyoimCD
19ILs66aLtNMlauOc5ZuHQOJjWkzftji3V3G4yZm8jVGiqOsH/B5XcvDAAVVjnik
wK987hMzowYBjKudCxPnD29s1X2PIQyx/JSlBNbI0I2G0bHTJhza1zLuAVxEJuoO
vG6J90Vu2kkb6702pQIDAQAB
-----END PUBLIC KEY-----]]

	publicKey = pkey.new(publicKeyStr)

	plainText = "This is some plain text"
        print(publicKey:toPEM("public"))

	encryptedText = publicKey:encrypt(plainText)

--        print(publicKey:toPEM("private"))

	privateKeyStr = [[-----BEGIN PRIVATE KEY-----
MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKpHCpYL8xG1mNg7
+vTuLKiKYIPX0guzrpou00yVq45zlm4dA4mNaTN+2OLdXcbjJmbyNUaKo6wf8Hld
y8MABVWOeKTAr3zuEzOjBgGMq50LE+cPb2zVfY8hDLH8lKUE1sjQjYbRsdMmHNrX
Mu4BXEQm6g68bon3RW7aSRvrvTalAgMBAAECgYBQzxIpD1a1qtb0l9KLdpTfD3yq
VTwrrYRJS7ufdtBJ9HUJoN9S4jdw5twLHj8o6hgJdxztc1Ill6rKDkdrLZFZuFF5
h9iUwxd+byH2XvtPDa/lueFTbQdUsqukyA7eH54vtJpZa/Ck52ZrU7IOGeru8n4y
zaJ7tuyuw3Wakd/XAQJBAOHX0KJ9mS3As/pyIgavgYnWLrbrcADfGmMrwZFHD/W5
STBz/JWvEKFBSkrKo5OQUwV8eANNHz1Q4f9TuPyTlSECQQDBA8hepH4qy8+PSe4Z
1RNp8IjneqSXbHJjPH0WzoLIQqikYSIC51f+RS258j5hA35x3kbVqjzV1qygL7HK
lK0FAkAl3JN6mknS1MqXgwjXTBcQb5rXSbM2QjDfTVefLmWrkUuG1vsScQ39qr90
uHIh7AEvG0XXb9d75RJuRq/tkCRhAkEAtg/VXsCWadPZsvUvbJp6N4G2AXLD8jlP
JKAX9f1Ri4ik/njI1ihV7fhfC3iesm/TQ6FA+6YawDJAntCeSdI36QJAGJbH8JGM
/fnFMjWIv9SfSFZsgiubqK08l4oWcWwEfj/sxJ0AbzzVeLTfbKQeC4jctOdQm/gw
apcqWMGkoUsqiw==
-----END PRIVATE KEY-----]]

	privateKey = pkey.new(privateKeyStr)
        privateKey:toPEM("public")

	decryptedText = privateKey:decrypt(encryptedText)

	lu.assertEquals(plainText, decryptedText)

end

lu.LuaUnit:run()
