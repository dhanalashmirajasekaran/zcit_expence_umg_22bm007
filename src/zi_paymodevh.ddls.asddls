@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Mode Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity ZI_PayModeVH
  as select from I_Language
{
      @Search.defaultSearchElement: true
  key cast( 'CASH' as abap.char(10) )           as PayModeId,
      cast( 'Cash' as abap.char(60) )            as PayModeName
}
where Language = $session.system_language

union select from I_Language
{ key cast( 'UPI' as abap.char(10) )            as PayModeId,
      cast( 'UPI' as abap.char(60) )             as PayModeName }
where Language = $session.system_language

union select from I_Language
{ key cast( 'CCRD' as abap.char(10) )           as PayModeId,
      cast( 'Corporate Card' as abap.char(60) )  as PayModeName }
where Language = $session.system_language
