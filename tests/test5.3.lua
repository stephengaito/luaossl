-- Test the 5.3 version of luaossl

-- To run these tests (in the base directory) type:  
--   lua5.3 tests/test5.3.lua

package.path  = "./tests/?.lua;" .. package.path 
package.cpath = "./tests/5.3/?.so;" .. package.cpath

require "testPKeyEncryption"
