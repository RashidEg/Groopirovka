<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--
    Два ключа для группировки Мюнха:
    1. По городу (уникальные города)
    2. По паре город+компания (уникальные компании внутри каждого города)
  -->
  <xsl:key name="by-city"    match="item" use="@city"/>
  <xsl:key name="by-city-org" match="item" use="concat(@city, '|', @org)"/>

  <xsl:output method="html" encoding="utf-8" indent="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <title>Города</title>
      </head>
      <body>
        <h1>Города и компании</h1>
        <ul>
          <!--
            Шаг 1 — уникальные города.
            Условие Мюнха: берём только тот элемент, который первым
            попадает в ключ by-city для своего значения @city.
          -->
          <xsl:for-each select="orgs/item[
              generate-id() = generate-id(key('by-city', @city)[1])
            ]">
            <xsl:sort select="@city"/>

            <xsl:variable name="city" select="@city"/>

            <li>
              <h3><xsl:value-of select="$city"/></h3>
              <p>Всего товаров: <xsl:value-of select="count(key('by-city', $city))"/></p>

              <ul>
                <!--
                  Шаг 2 — уникальные компании внутри текущего города.
                  Среди всех товаров этого города берём те, что первыми
                  попадают в ключ by-city-org для своей пары город|компания.
                -->
                <xsl:for-each select="key('by-city', $city)[
                    generate-id() = generate-id(
                      key('by-city-org', concat($city, '|', @org))[1]
                    )
                  ]">
                  <xsl:sort select="@org"/>

                  <xsl:variable name="org" select="@org"/>

                  <li>
                    <h4><xsl:value-of select="$org"/></h4>
                    <p>Всего товаров: <xsl:value-of
                        select="count(key('by-city-org', concat($city, '|', $org)))"/></p>

                    <!-- Шаг 3 — все товары этой компании в этом городе -->
                    <ul>
                      <xsl:for-each select="key('by-city-org', concat($city, '|', $org))">
                        <xsl:sort select="@title"/>
                        <li><xsl:value-of select="@title"/></li>
                      </xsl:for-each>
                    </ul>
                  </li>
                </xsl:for-each>
              </ul>
            </li>
          </xsl:for-each>
        </ul>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
