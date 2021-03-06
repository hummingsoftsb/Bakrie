
/****** Object:  StoredProcedure [Checkroll].[TaxAndRiceSetupUpdate]    Script Date: 25/8/2015 9:58:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- ====================================================
-- Created By : Gopinath
-- Modified By: SIVA SUBRAMANIAN S
-- Created date: 1 Oct 2009
-- Last Modified Date:07/07/2010
-- Module     : CheckRoll, RKPMS Web
-- Screen(s)  : TaxAndRiceSetup.aspx
-- Description: Procedure to update Tax And Rice Setup
-- =====================================================
ALTER PROCEDURE [Checkroll].[TaxAndRiceSetupUpdate]
--Add the parameters for the stored procedure here
--@ID INT
@Key NVARCHAR(50),
        @EstateID NVARCHAR(50),
        @DeductionCost         NUMERIC(18,2),
        @DeductionCostMax      NUMERIC(18,2),
        @Jamsostek             NUMERIC(18,2),
        @JkkAndJK              NUMERIC(18,2),
        @RAEmployee            NUMERIC(18,2),
        @RAHusbandOrWife       NUMERIC(18,2),
        @RAChild               NUMERIC(18,2),
        @RAPrice               NUMERIC(18,2),
        @GradeI                NUMERIC(18,2),
        @GradeIRange           NUMERIC(18,2),
        @GradeII               NUMERIC(18,2),
        @GradeIIRangeFrom      NUMERIC(18,2),
        @GradeIIRangeTo        NUMERIC(18,2),
        @GradeIII              NUMERIC(18,2),
        @GradeIIIRangeFrom     NUMERIC(18,2),
        @GradeIIIRangeTo       NUMERIC(18,2),
        @GradeIV               NUMERIC(18,2),
        @GradeIVRangeFrom      NUMERIC(18,2),
        @GradeIVRangeTo        NUMERIC(18,2),
        @GradeV                NUMERIC(18,2),
        @GradeVRange           NUMERIC(18,2),
        @GradeINPWP            NUMERIC(18,2),
        @GradeIRangeNPWP       NUMERIC(18,2),
        @GradeIINPWP           NUMERIC(18,2),
        @GradeIIRangeFromNPWP  NUMERIC(18,2),
        @GradeIIRangeToNPWP    NUMERIC(18,2),
        @GradeIIINPWP          NUMERIC(18, 2),
        @GradeIIIRangeFromNPWP NUMERIC(18, 2),
        @GradeIIIRangeToNPWP   NUMERIC(18, 2),
        @GradeIVNPWP           NUMERIC(18, 2),
        @GradeIVRangeFromNPWP  NUMERIC(18, 2),
        @GradeIVRangeToNPWP    NUMERIC(18, 2),
        @GradeVNPWP            NUMERIC(18, 2),
        @GradeVRangeNPWP       NUMERIC(18, 2),
        @TaxExemptionWorker    NUMERIC(18, 2),
        @TaxExemptionHusbWife  NUMERIC(18, 2),
        @TaxExemptionChild     NUMERIC(18, 2),
        @ModifiedBy			   NVARCHAR(50)  ,
        @FunctionalAllowanceP  NUMERIC(18, 2),
        @MaxAllowance		   NUMERIC(18, 2),
		@RANaturaPrice decimal(18,2),
		@RAAstekPrice decimal(18,2)
AS
        BEGIN TRY
                BEGIN
                        DECLARE @IsTaxAndRiceNoDuplicate NVARCHAR(50)--,
                        --@IsConcurrecyIdChanged TIMESTAMP
                        --   SELECT @IsTaxAndRiceNoDuplicate = CAS.TaxAndRiceSetupID
                        --                 FROM   Checkroll.TaxAndRiceSetup AS CAS
                        --                 WHERE  CAS.Id <> @ID AND
                        -- CAS.AttendanceSetupID           = @AttendanceSetupID
                        --AND  CAS.EstateID = @EstateID
                        UPDATE Checkroll.TaxAndRiceSetup
                        SET    DeductionCost        =@DeductionCost        ,
                               DeductionCostMax     =@DeductionCostMax     ,
                               Jamsostek            =@Jamsostek            ,
                               JkkAndJK             =@JkkAndJK             ,
                               RAEmployee           =@RAEmployee           ,
                               RAHusbandOrWife      =@RAHusbandOrWife      ,
                               RAChild              =@RAChild              ,
                               RAPrice              =@RAPrice              ,
                               GradeI               =@GradeI               ,
                               GradeIRange          =@GradeIRange          ,
                               GradeII              =@GradeII              ,
                               GradeIIRangeFrom     =@GradeIIRangeFrom     ,
                               GradeIIRangeTo       =@GradeIIRangeTo       ,
                               GradeIII             =@GradeIII             ,
                               GradeIIIRangeFrom    =@GradeIIIRangeFrom    ,
                               GradeIIIRangeTo      =@GradeIIIRangeTo      ,
                               GradeIV              =@GradeIV              ,
                               GradeIVRangeFrom     =@GradeIVRangeFrom     ,
                               GradeIVRangeTo       =@GradeIVRangeTo       ,
                               GradeV               =@GradeV               ,
                               GradeVRange          =@GradeVRange          ,
                               GradeINPWP           =@GradeINPWP           ,
                               GradeIRangeNPWP      =@GradeIRangeNPWP      ,
                               GradeIINPWP          =@GradeIINPWP          ,
                               GradeIIRangeFromNPWP =@GradeIIRangeFromNPWP ,
                               GradeIIRangeToNPWP   =@GradeIIRangeToNPWP   ,
                               GradeIIINPWP         =@GradeIIINPWP         ,
                               GradeIIIRangeFromNPWP=@GradeIIIRangeFromNPWP,
                               GradeIIIRangeToNPWP  =@GradeIIIRangeToNPWP  ,
                               GradeIVNPWP          =@GradeIVNPWP          ,
                               GradeIVRangeFromNPWP =@GradeIVRangeFromNPWP ,
                               GradeIVRangeToNPWP   =@GradeIVRangeToNPWP   ,
                               GradeVNPWP           =@GradeVNPWP           ,
                               GradeVRangeNPWP      =@GradeVRangeNPWP      ,
                               TaxExemptionWorker   =@TaxExemptionWorker   ,
                               TaxExemptionHusbWife =@TaxExemptionHusbWife ,
                               TaxExemptionChild    =@TaxExemptionChild    ,
                               ModifiedBy           =@ModifiedBy           ,
                               ModifiedOn           =GETDATE()			   , 
                               FunctionalAllowanceP	=@FunctionalAllowanceP ,					   
                               MaxAllowance			=@MaxAllowance  ,
							   RANaturaPrice=@RANaturaPrice,
							   RAAstekPrice = @RAAstekPrice
                        WHERE  TaxRiceSetupID       = @Key
                           AND EstateID             = @EstateID
                        SELECT 2
                               --END
                 END END TRY BEGIN CATCH DECLARE @ErrorMessage NVARCHAR(4000) DECLARE @ErrorSeverity INT DECLARE @ErrorState INT
                 SELECT @ErrorMessage  = ERROR_MESSAGE() ,
                        @ErrorSeverity = ERROR_SEVERITY(),
                        @ErrorState    = ERROR_STATE() RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState) END CATCH
                        --SP_HELPTEXT 'CHECKROLL.TaxAndRiceSetupUpdate'
















