SELECT
    VERSION() AS mysql_version,
    @@GLOBAL.secure_file_priv AS secure_file_priv,
    @@GLOBAL.local_infile AS local_infile;
########################################################