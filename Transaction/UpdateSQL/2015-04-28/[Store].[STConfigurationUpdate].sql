
/****** Object:  StoredProcedure [Store].[STConfigurationUpdate]    Script Date: 28/04/2015 19:29:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Created By :
-- Modified By:  Siva Subramanian S
-- Created date:
-- Last Modified Date:16th Nov 2009
-- Module     : Store
-- Screen(s)  :
-- Description:
-- =============================================
ALTER PROCEDURE [Store].[STConfigurationUpdate]
-- Add the parameters for the stored procedure here

@STConfigurationID nvarchar(50) output,
        @EstateID nvarchar(50),
        @IPRPrefix nvarchar(10),
        @IPRCommence nvarchar(10),
        @RGNPrefix nvarchar(10),
        @RGNCommence nvarchar(10),
        @ITNOutPrefix nvarchar(10),
        @ITNOutCommence nvarchar(10),
        @AdjustPrefix nvarchar(10),
        @AdjustCommence nvarchar(10),
        @LPOPrefix nvarchar(10),
        @LPOCommence nvarchar(10),
        @ISRPrefix nvarchar(10),
        @ISRCommence nvarchar(10),
        --@ConcurrencyId rowversion output,
        @ModifiedBy nvarchar(50),
        @ModifiedOn DATETIME
AS

        BEGIN TRY
			if(@ISRPrefix is null)
				set @ISRPrefix ='-'
			if(@ISRCommence is null)
			set @ISRCommence ='-'
                UPDATE Store.STConfiguration
                SET    EstateID         =@EstateID      ,
                       IPRPrefix        =@IPRPrefix     ,
                       IPRCommence      =@IPRCommence   ,
                       RGNPrefix        =@RGNPrefix     ,
                       RGNCommence      =@RGNCommence   ,
                       ITNOutPrefix     =@ITNOutPrefix  ,
                       ITNOutCommence   =@ITNOutCommence,
                       AdjustPrefix     =@AdjustPrefix  ,
                       AdjustCommence   =@AdjustCommence,
                       LPOPrefix        =@LPOPrefix     ,
                       LPOCommence      =@LPOCommence   ,
                       ISRPrefix        =@ISRPrefix     ,
                       ISRCommence      =@ISRCommence   ,
                       ModifiedBy       =@ModifiedBy    ,
                       ModifiedOn       =@ModifiedOn
                WHERE  STConfigurationID=@STConfigurationID

                SELECT 2;

                -- and ConcurrencyId=@ConcurrencyId;

                --SELECT @ConcurrencyId = ConcurrencyId FROM Store.STConfiguration WHERE STConfigurationID=@STConfigurationID;

        END TRY

        BEGIN CATCH

                DECLARE @ErrorMessage NVARCHAR(4000);
                DECLARE @ErrorSeverity INT;
                DECLARE @ErrorState    INT;

                SELECT @ErrorMessage  = ERROR_MESSAGE() ,
                       @ErrorSeverity = ERROR_SEVERITY(),
                       @ErrorState    = ERROR_STATE();

                RAISERROR (@ErrorMessage, -- Message text.
                @ErrorSeverity,           -- Severity.
                @ErrorState               -- State.
                );

        END CATCH;





