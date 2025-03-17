class ZCL_ZOV_DPC_EXT definition
  public
  inheriting from ZCL_ZOV_DPC
  create public .

public section.
protected section.

  methods MENSAGEMSET_CREATE_ENTITY
    redefinition .
  methods MENSAGEMSET_DELETE_ENTITY
    redefinition .
  methods MENSAGEMSET_GET_ENTITY
    redefinition .
  methods MENSAGEMSET_GET_ENTITYSET
    redefinition .
  methods MENSAGEMSET_UPDATE_ENTITY
    redefinition .
  methods OVCABECALHOSET_CREATE_ENTITY
    redefinition .
  methods OVCABECALHOSET_DELETE_ENTITY
    redefinition .
  methods OVCABECALHOSET_GET_ENTITY
    redefinition .
  methods OVCABECALHOSET_GET_ENTITYSET
    redefinition .
  methods OVCABECALHOSET_UPDATE_ENTITY
    redefinition .
  methods OVITEMSET_CREATE_ENTITY
    redefinition .
  methods OVITEMSET_DELETE_ENTITY
    redefinition .
  methods OVITEMSET_GET_ENTITY
    redefinition .
  methods OVITEMSET_GET_ENTITYSET
    redefinition .
  methods OVITEMSET_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZOV_DPC_EXT IMPLEMENTATION.


  method MENSAGEMSET_CREATE_ENTITY.

  endmethod.


  method MENSAGEMSET_DELETE_ENTITY.

  endmethod.


  method MENSAGEMSET_GET_ENTITY.

  endmethod.


  method MENSAGEMSET_GET_ENTITYSET.

  endmethod.


  method MENSAGEMSET_UPDATE_ENTITY.

  endmethod.


  METHOD ovcabecalhoset_create_entity.

    DATA:ld_lastid TYPE int4, "variavel com função de incrementar o OrdemID"
         ls_cabe   TYPE zovcab.

    "Objeto para emitir mensagem para quem estiver consumindo o serviço"
    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    "Pegando os dados da requisição"
    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).

    "Copiando os da entidade para a estrutura"
    MOVE-CORRESPONDING er_entity TO ls_cabe.

    "Preenchendo os campos que faltam na estrutura"
    ls_cabe-criacao_data    = sy-datum.
    ls_cabe-criacao_hora    = sy-uzeit.
    ls_cabe-criacao_usuario = sy-uname.

    "Pegando o ultimo ID"
    SELECT SINGLE MAX( ordemid )
      INTO ld_lastid
      FROM zovcab.

    "Incrementando mais +1 no ID"
    ls_cabe-ordemid = ld_lastid + 1.

    "Inserindo os novos dados na tabela ZOVCAB com base na estrutura"
    INSERT zovcab FROM ls_cabe.

    IF sy-subrc <> 0.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Erro ao inserir ordem'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

    "Atualizando a Entidade com todos os campos preenchidos"
    MOVE-CORRESPONDING ls_cabe TO er_entity.

    CONVERT
       DATE ls_cabe-criacao_data
       TIME ls_cabe-criacao_hora
       INTO TIME STAMP er_entity-datacriacao
       TIME ZONE sy-zonlo.

  ENDMETHOD.


  method OVCABECALHOSET_DELETE_ENTITY.

  endmethod.


  METHOD ovcabecalhoset_get_entity.
    DATA: lv_ordemid TYPE zovcab-ordemid,
          ls_key_tab LIKE LINE OF it_key_tab,
          ls_cab     TYPE zovcab.

    "Objeto que armazena qualquer msg de erro"
    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    "Imput"
    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'OrdemID'.
    IF sy-subrc <> 0.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'ID da ordem não informado'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

    lv_ordemid = ls_key_tab-value.

    SELECT SINGLE *
      INTO ls_cab
      FROM zovcab
      WHERE ordemid = lv_ordemid.

    IF sy-subrc = 0.

      MOVE-CORRESPONDING ls_cab TO er_entity.

      er_entity-criadopor = ls_cab-criacao_usuario.

      CONVERT DATE ls_cab-criacao_data
              TIME ls_cab-criacao_hora
         INTO TIME STAMP er_entity-datacriacao
         TIME ZONE sy-zonlo.
    ELSE.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'ID da ordem não encontrado'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

  ENDMETHOD.


  METHOD ovcabecalhoset_get_entityset.

    DATA: lt_cab       TYPE STANDARD TABLE OF zovcab,
          ls_cab       TYPE zovcab,
          ls_entityset LIKE LINE OF et_entityset,
          lt_orderby   TYPE STANDARD TABLE OF string,
          ls_orderby   TYPE string.

    LOOP AT it_order INTO DATA(ls_order).

      TRANSLATE ls_order-property TO UPPER CASE.
      TRANSLATE ls_order-order    TO UPPER CASE.

      IF ls_order-order = 'DESC'.
        ls_order-order = 'DESCENDING'.
      ELSE.
        ls_order-order = 'ASCENDING'.
      ENDIF.

      APPEND |{ ls_order-property } { ls_order-order }| TO lt_orderby.

    ENDLOOP.

    CONCATENATE LINES OF lt_orderby INTO ls_orderby SEPARATED BY ''.

    "Ordenação obrigatória caso nenhuma seja definida"
    IF ls_orderby = ''.
      ls_orderby = 'OrdemID ASCENDING'."Ficará fixo se não tiver nenhuma ordenação"
    ENDIF.

    "Pegando os dados da tabela ZOVCAB"
    SELECT *
      FROM zovcab
      WHERE (iv_filter_string)
      ORDER BY (ls_orderby)
      INTO TABLE @lt_cab
      UP TO @is_paging-top ROWS
      OFFSET @is_paging-skip.

    "Passando linha a linha e convertendo para entityset"
    LOOP AT lt_cab INTO ls_cab.

      CLEAR ls_entityset.

      "Passando os campos que dá para a entityset"
      MOVE-CORRESPONDING ls_cab TO ls_entityset.

      "Passando manualmente o criador pois no BD o nome do campo é diferente"
      ls_entityset-criadopor = ls_cab-criacao_usuario.

      "Juntando data e hora em um só campo na entityset"
      CONVERT DATE ls_cab-criacao_data
              TIME ls_cab-criacao_hora
         INTO TIME STAMP ls_entityset-datacriacao
         TIME ZONE sy-zonlo.

      APPEND ls_entityset TO et_entityset.
    ENDLOOP.

  ENDMETHOD.


  METHOD ovcabecalhoset_update_entity.

    "Objeto para emitir msg para quem estiver consumindo serviço"
    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    "Puxando dados da requisição e copiando para estrutura"
    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).

    "Puxando o campo chave OrdemID"
    er_entity-ordemid = it_key_tab[ name = 'OrdemID' ]-value.

    "Atualizando os campos específicos"
    UPDATE zovcab
       SET clienteid  = er_entity-clienteid
           totalitens = er_entity-totalitens
           totalfrete = er_entity-totalfrete
           totalordem = er_entity-totalordem
           status     = er_entity-status
     WHERE ordemid    = er_entity-ordemid.

    "Se o UPDATE der errado lança a exceção"
    IF sy-subrc IS NOT INITIAL.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Erro ao atualizar ordem'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

  ENDMETHOD.


  METHOD ovitemset_create_entity.

    DATA: LS_ITEM TYPE zovitem.

    "Objeto de mensagem"
    DATA(LO_MSG) = ME->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    "Carregando os dados da requisição e copiando para 'er_entity'"
    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).

    "Movendo os dados para a estrutura"
    MOVE-CORRESPONDING er_entity TO ls_item.

    "Caso o ID do item venha vazio, ele preenche pegando o último ID da tabela"
    IF er_entity-itemid = 0.
      SELECT SINGLE MAX( ITEMID )
        INTO er_entity-itemid
        FROM zovitem
        WHERE ordemid = er_entity-ordemid.

      "Auto incremento"
      er_entity-itemid = er_entity-itemid + 1.
    ENDIF.

    "Inserindo na tabela ZOVITEM"
    INSERT zovitem FROM ls_item.

    "Caso de um erro na inserção, ele cria uma msg de erro"
    IF SY-subrc <> 0.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Erro ao inserir o item na tabela ZOVITEM'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

  ENDMETHOD.


  method OVITEMSET_DELETE_ENTITY.

  endmethod.


  METHOD ovitemset_get_entity.
    DATA: ls_key_tab LIKE LINE OF it_key_tab, "Estrutura para extrair campos chaves da entidade"
          ls_item    TYPE zovitem, "Estrutura para armazenar itens que vem do banco"
          lv_error   TYPE flag. "Variavel que armazena flag de erro"

    "Objeto que armazena msg de erro"
    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    "Lendo o campo OrdemID no campo de chaves"
    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'OrdemID'.
    IF sy-subrc <> 0.
      lv_error = 'X'.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'ID da ordem não informado'
      ).
    ENDIF.

    ls_item-ordemid = ls_key_tab-value.

    "Lendo o campo ItemID no campo de chaves"
    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'ItemID'.
    IF sy-subrc <> 0.
      lv_error = 'X'.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'ID da item não informado'
      ).
    ENDIF.

    ls_item-itemid = ls_key_tab-value.

    "Lançando a exeption de uma vez com todos os erros"
    IF lv_error = 'X'.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.


    SELECT SINGLE *
      INTO ls_item
      FROM zovitem
      WHERE ordemid = ls_item-ordemid
      AND   itemid  = ls_item-itemid.

    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_item TO er_entity.
    ELSE.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Item não econtrado'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

  ENDMETHOD.


  METHOD ovitemset_get_entityset.
    DATA: lv_ordemid       TYPE int4,"Variavel para armazenar IDs"
          lt_ordemid_range TYPE RANGE OF int4, "Range de IDs de ordem"
          ls_ordemid_range LIKE LINE OF lt_ordemid_range, "Linha do range"
          ls_key_tab       LIKE LINE OF it_key_tab. "Linha da tabela de chaves"

    "Se o usuário informar a ordem, retorna somente os itens da mesma"
    READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'OrdemID'.

    IF sy-subrc = 0.

      lv_ordemid = ls_key_tab-value.

      CLEAR ls_ordemid_range.

      "Preenchendo o range"
      ls_ordemid_range-sign   = 'I'.
      ls_ordemid_range-option = 'EQ'.
      ls_ordemid_range-low    = lv_ordemid.
      APPEND ls_ordemid_range TO lt_ordemid_range.

    ENDIF.

    "Se lt_ordemid_range estiver vazio, vai retornar todos os itens da tabela"
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE et_entityset
      FROM zovitem
      WHERE ordemid IN lt_ordemid_range.

  ENDMETHOD.


  METHOD ovitemset_update_entity.

    "Objeto para emitir msg para quem estiver consumindo serviço"
     DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    "Puxando dados da requisição que vem do JSON e copiando para estrutura"
    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).

    er_entity-ordemid    = it_key_tab[ name = 'OrdemID' ]-value.
    er_entity-itemid     = it_key_tab[ name = 'ItemID' ]-value.
    er_entity-precototal = er_entity-quantidade * er_entity-precouni.

    "Atualizando os campos específicos"
    UPDATE zovitem
       SET material   = er_entity-material
           descricao  = er_entity-descricao
           quantidade = er_entity-quantidade
           precouni   = er_entity-precouni
           precototal = er_entity-precototal
     WHERE ordemid    = er_entity-ordemid
       AND itemid     = er_entity-itemid.

    "Se o UPDATE der errado lança a exceção"
    IF sy-subrc IS NOT INITIAL.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Erro ao atualizar ordem'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
