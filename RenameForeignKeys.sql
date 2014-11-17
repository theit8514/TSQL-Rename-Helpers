--
-- Generates a script to rename foreign keys to the pattern FK_tablename_fktable(_fkcolumns)
--
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#TempFKs') IS NOT NULL DROP TABLE #TempFKs
CREATE TABLE #TempFKs (
	TableName VARCHAR(255),
	ConstraintName VARCHAR(255),
	TargetName VARCHAR(255),
	SchemaName VARCHAR(255),
	Append VARCHAR(255),
	RenameTo AS ('FK_' + [TableName] + '_' + [TargetName])
)
INSERT INTO [#TempFKs] ([TableName],[ConstraintName],[TargetName],[SchemaName],[Append])
SELECT OBJECT_NAME([k].[parent_object_id]), OBJECT_NAME(object_id), OBJECT_NAME([k].[referenced_object_id]), SCHEMA_NAME([k].[schema_id]),
			STUFF((SELECT '_' + [sc].[name] FROM [sys].[foreign_key_columns] fkc
				INNER JOIN [sys].[syscolumns] sc ON [fkc].[parent_object_id] = [sc].[id] AND [fkc].[parent_column_id] = [sc].[colid]
				WHERE [fkc].[constraint_object_id] = [k].[object_id]
				FOR XML PATH('')), 1, 1, '')
		FROM [sys].[foreign_keys] k
		ORDER BY 1, 2, 3, 4

DECLARE @TableName VARCHAR(255), @ConstraintName VARCHAR(255), @TargetName varchar(255), @SchemaName varchar(255), @Append VARCHAR(255), @RenameTo VARCHAR(255)
DECLARE constraint_cursor CURSOR
FOR SELECT [TableName], [ConstraintName], [TargetName], [SchemaName], [Append], [RenameTo] FROM [#TempFKs]
OPEN constraint_cursor
FETCH NEXT FROM constraint_cursor INTO @TableName, @ConstraintName, @TargetName, @SchemaName, @Append, @RenameTo

WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @SqlScript VARCHAR(4000) = ''
		IF (SELECT COUNT(*) FROM [#TempFKs] WHERE [RenameTo] = @RenameTo) > 1
			SET @RenameTo = @RenameTo + '_' + @Append

        SET @SqlScript = 'sp_rename ''' + @SchemaName + '.[' + @ConstraintName + ']'', ''' + @RenameTo + ''', ''object''' + char(13) + char(10) + 'GO' + char(13) + char(10)
        --EXEC(@SqlScript)
        print @sqlscript
        FETCH NEXT FROM constraint_cursor INTO @TableName, @ConstraintName, @TargetName, @SchemaName, @Append, @RenameTo
    END 
CLOSE constraint_cursor;
DEALLOCATE constraint_cursor;
