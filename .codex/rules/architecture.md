# Arquitetura
Pages e widgets apresentam estado; controllers coordenam casos de uso; services concentram regras por domínio; repositories abstraem fontes de dados; `data/` implementa Firebase, Hive e seeds. Nunca acessar Firebase/Hive na apresentação. Evitar arquivos genéricos e abstração sem responsabilidade.
