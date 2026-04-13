@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GST Slab Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity ZI_GSTSlabVH
  as select from I_Language
{
      @Search.defaultSearchElement: true
  key cast( '0' as abap.char(10) )             as GSTCode,
      cast( '0% - Exempt' as abap.char(60) )   as GSTDesc
}
where Language = $session.system_language

union select from I_Language
{ key cast( '5' as abap.char(10) )             as GSTCode,
      cast( '5% - Essential' as abap.char(60) ) as GSTDesc }
where Language = $session.system_language

union select from I_Language
{ key cast( '12' as abap.char(10) )            as GSTCode,
      cast( '12% - Standard' as abap.char(60) ) as GSTDesc }
where Language = $session.system_language

union select from I_Language
{ key cast( '18' as abap.char(10) )            as GSTCode,
      cast( '18% - General' as abap.char(60) ) as GSTDesc }
where Language = $session.system_language

union select from I_Language
{ key cast( '28' as abap.char(10) )            as GSTCode,
      cast( '28% - Luxury' as abap.char(60) )  as GSTDesc }
where Language = $session.system_language
