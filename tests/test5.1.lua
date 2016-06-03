-- Test the 5.1 version of luaossl

-- To run these tests (in the base directory) type: 
--   lua5.1 tests/test5.1.lua

package.path  = package.path  .. ";./tests/?.lua"
package.cpath = package.cpath .. ";./tests/5.1/?.so"

require "testPKeyEncryption"
