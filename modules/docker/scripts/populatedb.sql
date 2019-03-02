USE "CU-1"
GO

IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;

GO

CREATE TABLE [Course] (
    [CourseID] int NOT NULL,
    [Title] nvarchar(max) NULL,
    [Credits] int NOT NULL,
    CONSTRAINT [PK_Course] PRIMARY KEY ([CourseID])
);

GO

CREATE TABLE [Student] (
    [ID] int NOT NULL IDENTITY,
    [LastName] nvarchar(max) NULL,
    [FirstMidName] nvarchar(max) NULL,
    [EnrollmentDate] datetime2 NOT NULL,
    CONSTRAINT [PK_Student] PRIMARY KEY ([ID])
);

GO

CREATE TABLE [Enrollment] (
    [EnrollmentID] int NOT NULL IDENTITY,
    [CourseID] int NOT NULL,
    [StudentID] int NOT NULL,
    [Grade] int NULL,
    CONSTRAINT [PK_Enrollment] PRIMARY KEY ([EnrollmentID]),
    CONSTRAINT [FK_Enrollment_Course_CourseID] FOREIGN KEY ([CourseID]) REFERENCES [Course] ([CourseID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Enrollment_Student_StudentID] FOREIGN KEY ([StudentID]) REFERENCES [Student] ([ID]) ON DELETE CASCADE
);

GO

CREATE INDEX [IX_Enrollment_CourseID] ON [Enrollment] ([CourseID]);

GO

CREATE INDEX [IX_Enrollment_StudentID] ON [Enrollment] ([StudentID]);

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20180626224812_InitialCreate', N'2.1.8-servicing-32085');

GO

EXEC sp_rename N'[Student].[FirstMidName]', N'FirstName', N'COLUMN';

GO

DECLARE @var0 sysname;
SELECT @var0 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Student]') AND [c].[name] = N'LastName');
IF @var0 IS NOT NULL EXEC(N'ALTER TABLE [Student] DROP CONSTRAINT [' + @var0 + '];');
ALTER TABLE [Student] ALTER COLUMN [LastName] nvarchar(50) NULL;

GO

DECLARE @var1 sysname;
SELECT @var1 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Student]') AND [c].[name] = N'FirstName');
IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Student] DROP CONSTRAINT [' + @var1 + '];');
ALTER TABLE [Student] ALTER COLUMN [FirstName] nvarchar(50) NULL;

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20180627162929_ColumnFirstName', N'2.1.8-servicing-32085');

GO

DECLARE @var2 sysname;
SELECT @var2 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Student]') AND [c].[name] = N'LastName');
IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Student] DROP CONSTRAINT [' + @var2 + '];');
ALTER TABLE [Student] ALTER COLUMN [LastName] nvarchar(50) NOT NULL;

GO

DECLARE @var3 sysname;
SELECT @var3 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Student]') AND [c].[name] = N'FirstName');
IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [Student] DROP CONSTRAINT [' + @var3 + '];');
ALTER TABLE [Student] ALTER COLUMN [FirstName] nvarchar(50) NOT NULL;

GO

DECLARE @var4 sysname;
SELECT @var4 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Course]') AND [c].[name] = N'Title');
IF @var4 IS NOT NULL EXEC(N'ALTER TABLE [Course] DROP CONSTRAINT [' + @var4 + '];');
ALTER TABLE [Course] ALTER COLUMN [Title] nvarchar(50) NULL;

GO

ALTER TABLE [Course] ADD [DepartmentID] int NOT NULL DEFAULT 0;

GO

CREATE TABLE [Instructor] (
    [ID] int NOT NULL IDENTITY,
    [LastName] nvarchar(50) NOT NULL,
    [FirstName] nvarchar(50) NOT NULL,
    [HireDate] datetime2 NOT NULL,
    CONSTRAINT [PK_Instructor] PRIMARY KEY ([ID])
);

GO

CREATE TABLE [CourseAssignment] (
    [InstructorID] int NOT NULL,
    [CourseID] int NOT NULL,
    CONSTRAINT [PK_CourseAssignment] PRIMARY KEY ([CourseID], [InstructorID]),
    CONSTRAINT [FK_CourseAssignment_Course_CourseID] FOREIGN KEY ([CourseID]) REFERENCES [Course] ([CourseID]) ON DELETE CASCADE,
    CONSTRAINT [FK_CourseAssignment_Instructor_InstructorID] FOREIGN KEY ([InstructorID]) REFERENCES [Instructor] ([ID]) ON DELETE CASCADE
);

GO

CREATE TABLE [Department] (
    [DepartmentID] int NOT NULL IDENTITY,
    [Name] nvarchar(50) NULL,
    [Budget] money NOT NULL,
    [StartDate] datetime2 NOT NULL,
    [InstructorID] int NULL,
    CONSTRAINT [PK_Department] PRIMARY KEY ([DepartmentID]),
    CONSTRAINT [FK_Department_Instructor_InstructorID] FOREIGN KEY ([InstructorID]) REFERENCES [Instructor] ([ID]) ON DELETE NO ACTION
);

GO

CREATE TABLE [OfficeAssignment] (
    [InstructorID] int NOT NULL,
    [Location] nvarchar(50) NULL,
    CONSTRAINT [PK_OfficeAssignment] PRIMARY KEY ([InstructorID]),
    CONSTRAINT [FK_OfficeAssignment_Instructor_InstructorID] FOREIGN KEY ([InstructorID]) REFERENCES [Instructor] ([ID]) ON DELETE CASCADE
);

GO

CREATE INDEX [IX_Course_DepartmentID] ON [Course] ([DepartmentID]);

GO

CREATE INDEX [IX_CourseAssignment_InstructorID] ON [CourseAssignment] ([InstructorID]);

GO

CREATE INDEX [IX_Department_InstructorID] ON [Department] ([InstructorID]);

GO

ALTER TABLE [Course] ADD CONSTRAINT [FK_Course_Department_DepartmentID] FOREIGN KEY ([DepartmentID]) REFERENCES [Department] ([DepartmentID]) ON DELETE CASCADE;

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20180628171754_ComplexDataModel', N'2.1.8-servicing-32085');

GO


