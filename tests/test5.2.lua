-- Test the 5.2 version of luaossl

-- To run these tests (in the base directory) type:  
--   lua5.2 tests/test5.2.lua

package.path  = "./tests/?.lua;" .. package.path 
package.cpath = "./tests/5.2/?.so;" .. package.cpath

require "testPKeyEncryption"
