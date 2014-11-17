--
-- Generates a script to rename primary keys to the pattern PK_tablename
--

DECLARE @TableName VARCHAR(255), @ConstraintName VARCHAR(255), @SchemaName varchar(255)
DECLARE constraint_cursor CURSOR
FOR 
	select b.name, kc.name, sc.name
	from sys.tables b
	join sys.schemas sc on b.schema_id = sc.schema_id
	inner join [sys].[key_constraints] kc ON [b].[object_id] = [kc].[parent_object_id]
	where b.name <> 'sysdiagrams'
	and b.type = 'U'
	AND [kc].[type] = 'PK'
	AND [sc].[name] <> 'tSQLt'

OPEN constraint_cursor
FETCH NEXT FROM constraint_cursor INTO @TableName, @ConstraintName, @SchemaName

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @SqlScript VARCHAR(4000) = ''
	SET @SqlScript = 'sp_rename ''' + @SchemaName + '.[' + @ConstraintName + ']'', ''PK_' + @TableName + ''', ''object''' + char(13) + char(10) + 'GO' + char(13) + char(10)
	--EXEC(@SqlScript)
	print @sqlscript
	FETCH NEXT FROM constraint_cursor INTO @TableName, @ConstraintName, @SchemaName
END 
CLOSE constraint_cursor;
DEALLOCATE constraint_cursor;
