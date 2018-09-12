-- Test the 5.1 version of luaossl

-- To run these tests (in the base directory) type: 
--   lua5.1 tests/test5.1.lua

package.path  = "./tests/?.lua;" .. package.path
package.cpath = "./tests/5.1/?.so;" .. package.cpath

require "testPKeyEncryption"
