/****** Object:  StoredProcedure [Checkroll].[OverTimeUpdate]    Script Date: 30/9/2015 2:39:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- ====================================================
-- Created By : Gopinath
-- Modified By:
-- Created date: 25 Sep 2009
-- Last Modified Date:
-- Module     : CheckRoll, RKPMS Web
-- Screen(s)  : OverTimeSetup.aspx
-- Description: Procedure to update OverTime Setup
-- =====================================================
ALTER PROCEDURE [Checkroll].[OverTimeUpdate]
--Add the parameters for the stored procedure here
--@ID INT,
@Key NVARCHAR(50),
        @EstateID NVARCHAR(50),
        @AttendanceSetupID NVARCHAR(50),
		@CropId NVARCHAR(50),
        --@DayStatus CHAR(1),
        @OvertimeTimes1      NUMERIC(18,2),
        @OvertimeMaxOTHours1 NUMERIC(18,2),
        @OvertimeTimes2      NUMERIC(18,2),
        @OvertimeMaxOTHours2 NUMERIC(18,2),
        @OvertimeTimes3      NUMERIC(18,2),
        @OvertimeMaxOTHours3 NUMERIC(18,2),
        @OvertimeTimes4      NUMERIC(18,2),
        @OvertimeMaxOTHours4 NUMERIC(18,2),
        @ModifiedBy NVARCHAR(50)
AS
        BEGIN TRY
                BEGIN
                        DECLARE @IsOverTimeNoDuplicate NVARCHAR(50)--,
                        --@IsConcurrecyIdChanged TIMESTAMP
                        SELECT @IsOverTimeNoDuplicate = CAS.OverTimeSetupID
                        FROM   Checkroll.OverTimeSetup AS CAS
                        WHERE  CAS.OvertimeSetupID                       <> @Key
                           AND CAS.AttendanceSetupID                      = @AttendanceSetupID
						   and cas.CropId = @CropId
                           AND CAS.EstateID                               = @EstateID
                        IF ISNULL(@IsOverTimeNoDuplicate, 'NotDuplicate') = 'NotDuplicate'
                        BEGIN
                                -- Update statements for procedure here
                                UPDATE Checkroll .OverTimeSetup
                                SET    AttendanceSetupID=@AttendanceSetupID,
                                       --DayStatus=@DayStatus,
                                       OvertimeTimes1     =@OvertimeTimes1     ,
                                       OvertimeMaxOTHours1=@OvertimeMaxOTHours1,
                                       OvertimeTimes2     =@OvertimeTimes2     ,
                                       OvertimeMaxOTHours2=@OvertimeMaxOTHours2,
                                       OvertimeTimes3     =@OvertimeTimes3     ,
                                       OvertimeMaxOTHours3=@OvertimeMaxOTHours3,
                                       OvertimeTimes4     =@OvertimeTimes4     ,
                                       OvertimeMaxOTHours4=@OvertimeMaxOTHours4,
                                       ModifiedBy         = @ModifiedBy        ,
                                       ModifiedOn         = GETDATE(),
									   CropID = @CropId
                                WHERE  OvertimeSetupID    = @Key

								--Update Checkroll.OverTimeSetupCrop
								--set CropId=@CropId
								--WHERE  OvertimeSetupID    = @Key
                                --WHERE ID = @ID --AND ConcurrencyId = @ConcurrencyId
                                SELECT 2
                         END ELSE BEGIN
                  SELECT 10
           END
           --END
END END TRY BEGIN CATCH DECLARE @ErrorMessage NVARCHAR(4000) DECLARE @ErrorSeverity INT DECLARE @ErrorState INT
           SELECT @ErrorMessage  = ERROR_MESSAGE() ,
                  @ErrorSeverity = ERROR_SEVERITY(),
                  @ErrorState    = ERROR_STATE() RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState) END CATCH
                  --SP_HELPTEXT 'CHECKROLL.OverTimeSetupUpdate'







