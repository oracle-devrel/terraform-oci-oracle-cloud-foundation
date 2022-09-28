# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.



/*

# The special test_assertions resource type, which belongs
# to the test provider we required above, is a temporary
# syntax for writing out explicit test assertions.
resource "test_assertions" "bucket" {  
# "component" serves as a unique identifier for this  
# particular set of assertions in the test results.  
  component = "bucket"   
  equal "bucket_name" {    
    description = "default bucket_name is natali-test-eu-627"    
    got         = module.main.bucket_name # value from the output
    want        = "natali-test-eu-627"  
  }
}


*/