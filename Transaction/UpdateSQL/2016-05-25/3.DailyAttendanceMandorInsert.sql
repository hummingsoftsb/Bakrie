
/****** Object:  StoredProcedure [Checkroll].[DailyAttendanceMandorInsert]    Script Date: 25/5/2016 11:33:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [Checkroll].[DailyAttendanceMandorInsert]
	-- Add the parameters for the stored procedure here
	@EstateID	as nvarchar(50),
	@ActiveMonthYearID	as nvarchar(50),
	@RDate	as datetime,
	@EmpID	as nvarchar(50),
	@AttendanceSetupID as	nvarchar(50),
	@DailyOT as numeric(18,4),
	@CreatedBy as	nvarchar(50),
	@CreatedOn as	datetime,
	@ModifiedBy as	nvarchar(50),
	@ModifiedOn	as datetime,
	@KraniPremiKg as numeric(18,2),
	@BlockId as nvarchar(50),
	@Tph as nvarchar(50)

AS
BEGIN TRY

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Insert into Checkroll.DailyAttendanceMandor(
	EstateID, 
	ActiveMonthYearID, 
	RDate, 
	EmpID, 
	AttendanceSetupID, 
	DailyOt,
	CreatedBy, 
	CreatedOn, 
	ModifiedBy, 
	ModifiedOn,
	KraniPremiKg,
	BlockId,
	Tph)
	VALUES(
	@EstateID,
	@ActiveMonthYearID,
	@RDate,
	@EmpID,
	@AttendanceSetupID,
	@DailyOT,
	@CreatedBy,
	@CreatedOn,
	@ModifiedBy,
	@ModifiedOn,
	@KraniPremiKg,
	@BlockId,
	@Tph
	)

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
END CATCH


