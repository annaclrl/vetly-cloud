package com.vetly.vetly_java.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.util.Arrays;
import java.util.List;

public class ValueOfEnumListValidator implements ConstraintValidator<ValueOfEnum, List<String>> {
    private List<String> acceptedValues;

    @Override
    public void initialize(ValueOfEnum annotation) {
        acceptedValues = Arrays.stream(annotation.enumClass().getEnumConstants())
                .map(Enum::name)
                .toList();
    }

    @Override
    public boolean isValid(List<String> values, ConstraintValidatorContext context) {
        if (values == null || values.isEmpty()) return false;

        List<String> invalidos = values.stream()
                .filter(v -> !acceptedValues.contains(v.toUpperCase()))
                .toList();

        if (!invalidos.isEmpty()) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate(
                    "Valores inválidos: " + invalidos + ". Opções aceitas: " + acceptedValues
            ).addConstraintViolation();
            return false;
        }

        return true;
    }
}
