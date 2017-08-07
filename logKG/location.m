% Given a blank alternative matrix altMatrix (except for the range of bid
% values) to be used with logKG and a city, this function returns the
% alternative matrix with the indicator variables for the specific city,
% region, and country, turned "on". 
%
% Assumes that there are x countries, x^2 regions (x regions in every 
% country), x^3 cities (x cities in every region). Assumes that the 
% first x cities (indices 1,2,..,x) are in the first region and the second 
% x cities (indices x+1,x+2,...,2x) are in the second region and so forth.
% Also assumes the same of regions and countries. 

function altMatrix = location(altMatrix,city)

global nCountries;
nRegions = nCountries*nCountries;
nCities = nCountries*nCountries*nCountries;

country = idivide((city - 1),int32(nCities/nCountries)) + 1;
region = idivide((city - 1),int32(nCities/nRegions)) + 1;
altMatrix(:,1+country) = 1;
altMatrix(:,1+nCountries+region) = 1;
altMatrix(:,1+nCountries+nRegions+city) = 1;

end

