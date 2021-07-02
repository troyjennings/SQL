USE [master]
GO

/****** Object:  Table [dbo].[DBMoves]    Script Date: 4/28/2020 2:01:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DB_Move](
	DBName NVARCHAR(100) NOT NULL,
	SourceFullPath NVARCHAR(3000) NOT NULL, 
	SourceLogPath NVARCHAR(3000) NOT NULL, 
	SourceDiffPath NVARCHAR(3000),
	DataDrivePath NVARCHAR(100) NOT NULL, 
	LogDrivePath NVARCHAR(100) NOT NULL,
	MoveStatus INT NOT NULL,
	LastUpdate DATETIME,
 CONSTRAINT [PK_DB_Move] PRIMARY KEY CLUSTERED 
(
	DBName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


CREATE TABLE dbo.DB_Errors
         (ErrorID        INT IDENTITY(1, 1),
          UserName       VARCHAR(100),
          ErrorNumber    INT,
          ErrorState     INT,
          ErrorSeverity  INT,
          ErrorLine      INT,
          ErrorProcedure VARCHAR(MAX),
          ErrorMessage   VARCHAR(MAX),
          ErrorDateTime  DATETIME)
GO

/*
CREATE TABLE [dbo].[DB_MoveTemp](
	DBName NVARCHAR(100) NOT NULL,
	SizeMB INT NOT NULL,
	MoveStatus INT NOT NULL
 CONSTRAINT [PK_DB_MoveTemp] PRIMARY KEY CLUSTERED 
(
	DBName ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
*/