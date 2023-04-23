
{-# LANGUAGE InstanceSigs #-}  


type Ident = Int
type Nombre = String
type Precio = Float
type Cantidad = Float

--EJERCICIO 6

data Producto = Producto Ident Nombre Precio

instance Eq Producto where 
    (==) :: Producto -> Producto -> Bool
    (==) (Producto id1 name1 price1)(Producto id2 name2 price2) = (Producto id1 name1 price1) == (Producto id2 name2 price2)
    (/=) :: Producto -> Producto -> Bool
    (/=)(Producto id1 name1 price1)(Producto id2 name2 price2) = not((id1,name1,price1) == (id2,name2,price2))


 

instance Show Producto where
    show (Producto id nombre precio) = show (id, nombre, precio)




data Pedido = Pedido Producto Cantidad| PedidoUnitario Producto | (:+) Producto Cantidad 

instance Show Pedido where
    show (Pedido producto cantidad) = "Pedido " ++ show producto ++ "con cantidad" ++ show cantidad
    show (PedidoUnitario producto) = "Pedido Unitario " ++ show producto
    show ((:+) producto cantidad) = "Pedido usando el :+" ++ show producto ++ "con cantidad" ++ show cantidad -- así no daría error, pero ns cuándo hacemos este ultimo show
instance Eq Pedido where 
    (==) :: Pedido -> Pedido -> Bool
    (==) (Pedido producto1 _)(Pedido producto2 _) = producto1 == producto2
    (==) (PedidoUnitario producto1)(PedidoUnitario producto2) = producto1 == producto2
    (==) ((:+) producto1 _)((:+) producto2 _) = producto1 == producto2
    (/=) :: Pedido -> Pedido -> Bool
    (/=) (Pedido producto1 _)(Pedido producto2 _) = producto1 == producto2
    (/=) (PedidoUnitario  producto1)(PedidoUnitario producto2) = producto1 == producto2
    (/=) ((:+) producto1 _)((:+) producto2 _) = producto1 == producto2

data Compra = Compra [Pedido]
instance Show Compra where
    show :: Compra -> String
    show (Compra []) = ""
    show (Compra (pedido : xs)) = show pedido ++" , "++ show (Compra xs)






--FUNCIONES PARA CONTROLAR ERRORES

productoS :: Int -> String -> Float -> Producto 
productoS id nombre precio 
  | precio <= 0 = error  "el precio del producto no puede ser negativo"
  | id <= 0 =  error "el identificador introducido no es correcto"
  | nombre == "" = error  "el nombre del producto no se ha establecido"
  | otherwise = (Producto id nombre precio)

pedidoS :: Producto -> Cantidad -> Pedido
--no hace falta una función de comprobación para crear un pedidoUnitario ya que nos hemos asegurado de que el 
--producto SABEMOS que está creado con los datos correctos
pedidoS (Producto codigo nombre precio) cantidad 
  | cantidad < 0 = error "el pedido no puede tener cantidad negativa"
  | otherwise = (Pedido (Producto codigo nombre precio) cantidad)



product0 = productoS 1 "la copa" 2000 
product1 = productoS 2 "yate" 30000000 --yate
product2 = productoS 3 "naranja" 2
order0 = PedidoUnitario product0 
order1 = pedidoS product1 3
order2 = pedidoS product2 5
pur0 = Compra [order0,order1]
pur1 = Compra [order2]

pedido_defectuoso = Pedido product1 (-1)
compra_defectuosa = Compra [pedido_defectuoso,order1]





--no tiene sentido reescribir las funciones ToString ya que usamos el show.

precioProducto :: Producto -> Float  --son muy sencillas estas dos, no habra que cambiar imagino
precioProducto (Producto id nombre precio) = precio

precioPedido :: Pedido -> Float
precioPedido (Pedido (Producto id nombre precio) cantidad) = precio * cantidad
precioPedido (PedidoUnitario (Producto id nombre precio)) = precio

precioCompra :: Compra -> Float
precioCompra (Compra pedidos)= foldr ((+) . precioPedido) 0 pedidos

fusionaCompras :: Compra -> Compra -> Compra  -- FUNCIONAN AMBAS FUSIONA COMPRAS
fusionaCompras (Compra c1)(Compra c2) = Compra (concat [c1,c2]) --concat es una funcion de orden superior


--crear una lista por compresion,creamos dos compras con solo el producto ordenado
--(una con los pedidos y otra con pedidos unitarios) y usar precio compra

precioProductoCompra :: Compra -> Producto -> Float 

precioProductoCompra (Compra pedidos)(Producto a b c) = 
 precioCompra (Compra [ pedidoS (Producto id nombre precio) cantidad |(a,b,c) == (id,nombre,precio),(Pedido (Producto id nombre precio) cantidad)  
 <- pedidos ])+
 precioCompra (Compra [ PedidoUnitario (Producto id nombre precio)  | (a,b,c) == (id,nombre,precio),(PedidoUnitario (Producto id nombre precio))  
 <- pedidos])

buscaPedidosConProducto :: Compra -> Producto -> Compra
buscaPedidosConProducto (Compra pedidos) (Producto a b c) = 
    
    let c1 =(Compra [ pedidoS (Producto id nombre precio) cantidad | (Pedido (Producto id nombre precio) cantidad)  <- pedidos, (Producto a b c) == (Producto id nombre precio)])
        c2 =(Compra [ PedidoUnitario (Producto id nombre precio)  | (PedidoUnitario (Producto id nombre precio))  <- pedidos,(Producto a b c) == (Producto id nombre precio)])
    in fusionaCompras c1 c2 

buscaPedidosConProductos :: Compra -> [Producto] -> Compra
--usamos la funcion anterior y foldl
buscaPedidosConProductos (Compra pedidos) prods= 
        let c1 =(Compra [ pedidoS (Producto id nombre precio) cantidad | (Pedido (Producto id nombre precio) cantidad)  <- pedidos, elem (Producto id nombre precio) prods])
            c2 =(Compra [ PedidoUnitario (Producto id nombre precio)  | (PedidoUnitario (Producto id nombre precio))  <- pedidos,elem (Producto id nombre precio) prods])
        in fusionaCompras c1 c2

eliminaProductoCompra :: Compra -> Producto -> Compra
eliminaProductoCompra (Compra pedidos) prod= 
        let c1 =(Compra [ pedidoS (Producto id nombre precio) cantidad | (Pedido (Producto id nombre precio) cantidad)  <- pedidos, (Producto id nombre precio)/=prod])
            c2 =(Compra [ PedidoUnitario (Producto id nombre precio)  | (PedidoUnitario (Producto id nombre precio))  <- pedidos,(Producto id nombre precio)/=prod])
        in fusionaCompras c1 c2

eliminaCompraCantidad :: Compra -> Cantidad -> Compra
eliminaCompraCantidad(Compra pedidos) cant_max =
        let c1 = Compra [ pedidoS (Producto id nombre precio) cantidad | (Pedido (Producto id nombre precio) cantidad)  <- pedidos,cant_max>=cantidad]
            c2 =Compra [ PedidoUnitario (Producto id nombre precio)  | cant_max == 1,(PedidoUnitario (Producto id nombre precio))  <- pedidos ]
        in fusionaCompras c1 c2


cantidadProducto :: Compra -> Producto -> Float
--lo usamos para la funcion siguiente,y devuelve el numero de repeticiones que tiene un producto en una compra
cantidadProducto (Compra pedidos) (Producto id nombre precio) = (precioProductoCompra (Compra pedidos) (Producto id nombre precio)/precio)
--si dividimos el precio total de un producto en la compra entre el precio de la unidad obtenemos la cantidad del producto presente en la compra.

 




test :: Compra -> [Producto]
test (Compra pedidos) = 
    let prods=[Producto id nombre precio | (Pedido (Producto id nombre precio) cantidad)  <- pedidos]++
              [Producto id nombre precio | PedidoUnitario (Producto id nombre precio)  <- pedidos]
    in []
main2 :: IO ()
main2 = do
        print("Comienzo de las ejecuciones del main2")
        print("")
        
        --print(pedidoS product0 (-1) )




        print(eliminaProductoCompra pur0 product0)
        print(precioCompra pur0)
        --print(fusionaCompras pur0 pur1)
        print "yee"
        print(precioProductoCompra pur0 product1)
        --print(buscaPedidosConProducto pur0 product0)
        --print(buscaPedidosConProductos pur0 [product0,product1])
        
        print(eliminaCompraCantidad pur0 1)
        print()  --FALTARÍA AQUÍ LA FUNCIÓN DE ELIMINACIÓN DE REPETICIONES
        print()
        print()
        print()
        print()
        print()
        print()
        print()
        print()
        print("")
        print("Fin de las ejecuciones del main2")

        
