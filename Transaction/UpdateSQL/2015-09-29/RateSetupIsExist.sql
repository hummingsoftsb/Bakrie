
/****** Object:  StoredProcedure [Checkroll].[RateSetupIsExist]    Script Date: 14/10/2015 9:55:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








-- =============================================
-- Created By : 
-- Modified By: Siva Subramanian S
-- Created date:
-- Last Modified Date:16th Nov 2009
-- Module     : CheckRoll
-- Screen(s)  :
-- Description:
-- =============================================
ALTER PROCEDURE [Checkroll].[RateSetupIsExist]

-- Add the parameters for the stored procedure here

@RateSetupID nvarchar(50),
        @Category nvarchar(50),
        @EstateID nvarchar(50),
        @Grade    CHAR(1),
        @HIPLevel INT,
        @code nvarchar(50)

AS

        IF @RateSetupID IS NULL
        BEGIN

                IF (@Category ='KHT')
                OR
				(
                        @Category ='KHL'
                ) 
				OR
				(@Category = 'PKWT')
                BEGIN
                        SELECT COUNT(*)
                        FROM   Checkroll .RateSetup
                        WHERE  Category =@Category
                           AND EstateID =@EstateID
                END

                IF (@Category ='KT')


                BEGIN
                        SELECT COUNT(*)
                        FROM   Checkroll .RateSetup
                        WHERE  Grade    =@Grade
                           AND HIPLevel =@HIPLevel
                           AND Code     =@code
                           AND EstateID =@EstateID
                END
        END


        ELSE

        BEGIN
                IF (@Category ='KHT')
                OR
                (
                        @Category ='KHL'
                )
				OR
				(@Category = 'PKWT')
                
                BEGIN
                        SELECT COUNT(*)
                        FROM   Checkroll .RateSetup
                        WHERE  Category     =@Category
                           AND EstateID     =@EstateID
                           AND RateSetupID <>@RateSetupID
                END

                IF (@Category ='KT')


                BEGIN
                        SELECT COUNT(*)
                        FROM   Checkroll .RateSetup
                        WHERE  Grade        =@Grade
                           AND HIPLevel     =@HIPLevel
                           AND Code         =@code
                           AND EstateID     =@EstateID
                           AND RateSetupID <>@RateSetupID
                END

        END











