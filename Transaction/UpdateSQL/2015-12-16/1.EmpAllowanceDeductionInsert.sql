/****** Object:  StoredProcedure [Checkroll].[EmpAllowanceDeductionInsert]    Script Date: 16/12/2015 1:46:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















-- Batch submitted through debugger: SQLQuery3.sql|0|0|C:\Users\Ashok\AppData\Local\Temp\~vsB37E.sql




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [Checkroll].[EmpAllowanceDeductionInsert]
	-- Add the parameters for the stored procedure here
	@EmpAllowDedID nvarchar(50) output,
	@EstateID nvarchar(50),
	@EstateCode nvarchar(50),
	@EmpID nvarchar(50),
	@AllowDedID nvarchar(50),
	@Amount numeric(18, 2),
	@Type char(1), 
	@StartDate date,
	@EndDates date,
	@CreatedBy nvarchar(50),
	@CreatedOn datetime,
	@ModifiedBy nvarchar(50),
	@ModifiedOn datetime
AS

	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	-- SET NOCOUNT ON;
BEGIN TRY
  
	
	-- Get New Primary key
    Declare @count int
    
	delete from Checkroll.EmpAllowanceDeduction where empid = @EmpID and AllowDedID = @AllowDedID
	and StartDate = @StartDate and EndDates = @EndDates
    

	SELECT @EmpAllowDedID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + 1) AS VARCHAR)
                FROM   Checkroll.EmpAllowanceDeduction
                DECLARE @i INT = 2
                WHILE EXISTS
                (SELECT id
                FROM    Checkroll.EmpAllowanceDeduction
                WHERE   EmpAllowDedID = @EmpAllowDedID
                )
                BEGIN
                        SELECT @EmpAllowDedID = @EstateCode + 'R' + CAST ( (ISNULL(MAX(id),0) + @i) AS VARCHAR)
                        FROM    Checkroll.EmpAllowanceDeduction
                        SET @i = @i + 1
                END
    
    
	INSERT INTO Checkroll.EmpAllowanceDeduction
		(
		EmpAllowDedID,
		EstateID,
		EmpID,
		AllowDedID,
		Amount,
		Type, 
		StartDate,
		EndDates,
		CreatedBy,
		CreatedOn,
		ModifiedBy,
		ModifiedOn)
	VALUES
		(
		@EmpAllowDedID,
		@EstateID,
		@EmpID,
		@AllowDedID,
		@Amount,
		@Type, 
		@StartDate,
		@EndDates,
		@CreatedBy,
		@CreatedOn,
		@ModifiedBy,
		@ModifiedOn
		);

		
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;















