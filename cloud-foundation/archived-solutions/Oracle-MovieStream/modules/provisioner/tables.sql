-- -- **Copyright © 2023, Oracle and/or its affiliates.
-- -- **All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


-- Then, connect as MOVIESTREAM user and run the following:    
-- *Moviestream password is hardcoded to: watchS0meMovies#*
  
    declare 
        l_uri varchar2(500) := 'https://objectstorage.us-phoenix-1.oraclecloud.com/n/adwc4pm/b/workshop_utilities/o/movieapp/movieapp-add-data.sql';
    begin
        dbms_cloud_repo.install_sql(
            content => to_clob(dbms_cloud.get_object(object_uri => l_uri))
        );
    end;
    /

exit;
/