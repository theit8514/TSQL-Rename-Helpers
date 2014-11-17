--
-- Generates a script to rename defaults to the pattern DF_tablename_columnname
--

DECLARE @TableName VARCHAR(255), @ConstraintName VARCHAR(255), @ColumnName varchar(255), @SchemaName varchar(255)
DECLARE constraint_cursor CURSOR
    FOR 
        select b.name, c.name, a.name, sc.name
        from sys.all_columns a 
        inner join sys.tables b on a.object_id = b.object_id
        join sys.schemas sc on b.schema_id = sc.schema_id
        inner join sys.default_constraints c on a.default_object_id = c.object_id
        where 
            b.name <> 'sysdiagrams'
            and b.type = 'U'

OPEN constraint_cursor
FETCH NEXT FROM constraint_cursor INTO @TableName, @ConstraintName, @ColumnName, @SchemaName

WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @SqlScript VARCHAR(4000) = ''
        SET @SqlScript = 'sp_rename ''' + @SchemaName + '.[' + @ConstraintName + ']'', ''DF_' + @TableName + '_' + @ColumnName + ''', ''object''' + char(13) + char(10) + 'GO' + char(13) + char(10)
        --EXEC(@SqlScript)
        print @sqlscript
        FETCH NEXT FROM constraint_cursor INTO @TableName, @ConstraintName, @ColumnName, @SchemaName
    END 
CLOSE constraint_cursor;
DEALLOCATE constraint_cursor;
