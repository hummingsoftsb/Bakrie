
/****** Object:  StoredProcedure [Checkroll].[RateSetupAddConfigurableUpdate]    Script Date: 7/7/2015 5:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Checkroll].[RateSetupAddConfigurableUpdate]
--Add the parameters for the stored procedure here
@id int,
		@Description varchar(200),
        @Category varchar(50),
        @EstateID nvarchar(50),
        @Percentage decimal(18,2),
        @CalcType smallint,
        @AllowDeductionCode varchar(50)
AS
        BEGIN TRY
             update Checkroll.RateSetupAddConfigurable  set
			 [Description]=@Description, 
			 Category=@Category, 
			 EstateID=@EstateID,
			 Percentage=@Percentage,
			 CalcType=@CalcType,
			 AllowDeductionCode=@AllowDeductionCode
			 where id=@id

		END TRY 
		BEGIN CATCH DECLARE @ErrorMessage NVARCHAR(4000);
                 
                 DECLARE @ErrorSeverity INT;
                 DECLARE @ErrorState    INT;
                 SELECT @ErrorMessage  = ERROR_MESSAGE() ,
                        @ErrorSeverity = ERROR_SEVERITY(),
                        @ErrorState    = ERROR_STATE();
                 
                 RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
         END CATCH;








