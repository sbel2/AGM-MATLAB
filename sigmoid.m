function f= sigmoid(x,minnie,height,inflection,slope);


f = minnie + height ./ (1 + exp(-(x-inflection)./slope)); %fitting function
